#!/bin/bash
set -m # enable job control

RPCPORT=8545
WSPORT=8546
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

# geth is dumb and won't let us run it in the background, and nohup redirects to file when run in a script
nohup geth \
  --datadir "${ROOT}/chain" \
  --keystore "${ROOT}/keys" \
  --password "${ROOT}/password.txt" \
  --unlock "${UNLOCK_ACCOUNT}" \
  --verbosity 2 --mine \
  --ws --wsapi eth,net,web3,personal --wsport $WSPORT \
  --rpc --rpcapi eth,net,web3,personal,miner --rpcaddr 0.0.0.0 --rpcport $RPCPORT \
  --targetgaslimit 6500000 < /dev/null &
eth_pid=$!

tail -F nohup.out 2>/dev/null &
tail_pid=$!

cleanup() {
  kill $tail_pid $eth_pid > /dev/null 2>&1
  exit 1
}

trap cleanup INT TERM

eth_call() {
  local response
  response=$(curl --silent --show-error localhost:$RPCPORT -H "Content-Type: application/json" -X POST --data "${response}" 2>&1)
  if [[ \
    "${response}" == *'"error":'* || \
    "${response}" == *'Connection refused'* || \
    "${response}" == *'bad method'* \
  ]] ; then
    echo "not ready"
  else
    echo "ready"
  fi
}

eth_running() {
  kill -0 $eth_pid > /dev/null 2>&1
}

wait_for_node() {
  while eth_running && [[ $(eth_call $INITIAL_TX_DATA) == "not ready" ]] ; do sleep 1; done
}

wait_for_node &
wait $!

if ! eth_running ; then
  >&2 echo "Failed to start Ethereum Node, exiting"
  RESULT=1
else
  echo -e "\e[32mGeth up and running!\e[0m"
  fg %1
  RESULT=0
fi

cleanup
exit $RESULT
