#!/bin/bash
set -m # enable job control

WSPORT=8456
ROOT=/geth
UNLOCK_ACCOUNT="0xc5ed899b0878656feb06467e2e9ede3ae73cbcb7"
read -r -d INITIAL_TX_DATA << --EOF
{
  "jsonrpc":"2.0",
  "method":"eth_sendTransaction",
  "params": [{
    "value": "0x0",
    "to":"0x0000000000000000000000000000000000000000",
    "from":"${UNLOCK_ACCOUNT}",
    "data":"0x",
    "gasPrice":"0x1"
  }],
  "id": 1
}
--EOF

while getopts p:r:a option ; do
  case "${option}" in
    p) WSPORT=${OPTARG};;
    r) ROOT=${OPTARG};;
    a) UNLOCK_ACCOUNT=${OPTARG};;
  esac
done

# geth is dumb and won't let us run it in the background, and nohup redirects to file when run in a script
nohup geth \
  --datadir "${ROOT}/chain" \
  --keystore "${ROOT}/keys" \
  --password "${ROOT}/password.txt" \
  --unlock "${UNLOCK_ACCOUNT}" \
  --verbosity 2 --mine \
  --ws --wsapi eth,net,web3,personal --wsport $WSPORT \
  --rpc --rpcapi eth,net,web3,personal,miner --rpcaddr 0.0.0.0 \
  --targetgaslimit 6500000 < /dev/null &
eth_pid=$!

tail -F nohup.out &
tail_pid=$!

# Just in case...
trap "kill $tail_pid $eth_pid > /dev/null 2>&1" EXIT SIGINT

function eth_call {
  curl  --silent --show-error localhost:$WSPORT -X POST -H "Content-Type: application/json" --data "$1" > /dev/null 2>&1
}

function eth_running {
  kill -0 $eth_pid > /dev/null 2>&1
}

# spin until node is connectable
while eth_running && ! eth_call '{"jsonrpc":"2.0","method":"net_version","id": 1}' ; do sleep 1; done

if ! eth_running ; then
  >&2 echo "Failed to start Ethereum Node, exiting"
  exit 1
elif ! eth_call $INITIAL_TX_DATA ; then
  >&2 echo "Could not communicate with Ethereum Node, returned error ${?}"
  exit 2
else
  echo -e "\e[32mGeth up and running!\e[0m"
  fg %1
  exit 0
fi

