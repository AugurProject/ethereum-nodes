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

# spin until node is ready
spinner() {
  local i sp n
  sp='/-\|'
  n=${#sp}
  printf ' '
  while sleep 0.1; do
    printf "%s\b" "${sp:i++%n:1}" 
  done
}

spinner "Waiting for geth to be ready" &
spinner_pid=$!

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

tail -F nohup.out 2>/dev/null &
tail_pid=$!

cleanup() {
  kill $spinner_pid $tail_pid $eth_pid > /dev/null 2>&1
  exit 1
}

trap cleanup INT TERM

eth_call() {
  local response
  response=$(curl  --silent --show-error localhost:$WSPORT -X POST -H "Content-Type: application/json" --data "${response}" 2>&1)
  if [[ \
    "${response}" == *'"error":'* || \
    "${response}" == *'Connection refused'* || \
    "${response}" == *"bad method"* \
  ]] ; then
    echo "not ready"
  else
    >&2 echo $response
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
wait
kill $spinner_pid

if ! eth_running ; then
  >&2 echo "Failed to start Ethereum Node, exiting"
  RESULT=1
else
  echo -e "\e[32mGeth up and running!\e[0m"
  fg %2
  RESULT=0
fi

cleanup
exit $RESULT
