#!/bin/bash
# make it so we can do job control inside the script (fg at the end)
set -m


WSPORT=8456
ROOT=/geth
UNLOCK_ACCOUNT="0xc5ed899b0878656feb06467e2e9ede3ae73cbcb7"

while getopts p:r:a option ; do
  case "${option}" in
    p) WSPORT=${OPTARG};;
    r) ROOT=${OPTARG};;
    a) UNLOCK_ACCOUNT=${OPTARG};;
  esac
done

# geth is dumb and won't let us run it in the background, and nohup redirects to file when run in a script
tail -F geth.log &
tail_pid=$!

nohup geth \
  --datadir "${ROOT}/chain" \
  --keystore "${ROOT}/keys" \
  --password "${ROOT}/password.txt" \
  --unlock "${UNLOCK_ACCOUNT}" \
  --verbosity 2 --mine \
  --ws --wsapi eth,net,web3,personal --wsport $WSPORT \
  --rpc --rpcapi eth,net,web3,personal,miner --rpcaddr 0.0.0.0 \
  --targetgaslimit 6500000 > geth.log &
geth_pid=$!

# spin until node is connectable
while $(ps --no-headers -q "$geth_pid") = "$geth_pid"  && ! nc -w 1 -q 1 localhost $WSPORT < /dev/null; do sleep 1; done

if ps -o pid= -q "$geth_pid" > /dev/null 3>&1 ; then
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

  if curl  --silent --show-error localhost:$WSPORT -X POST -H "Content-Type: application/json" --data "${INITIAL_TX_DATA}" ; then
    # bring geth to the foreground
    fg %nohup
  else
    echo "Could not communicate with GETH, returned error ${?}"
  fi
fi

wait $geth_pid
kill $tail_pid
