#!/bin/bash

RPCPORT=8545
WSPORT=8546
if [[ "${ROOT}" == "" ]] ; then ROOT="/geth" ; fi
[[ "${UNLOCK_ACCOUNT}" != "" ]] || UNLOCK_ACCOUNT="0xc5ed899b0878656feb06467e2e9ede3ae73cbcb7"

ROOT=$(readlink -f $ROOT)

source ./common_start.sh

node_start() {
  # geth is dumb and won't let us run it in the background, and nohup redirects to file when run in a script
  nohup geth \
    --datadir "${ROOT}/chain" \
    --keystore "${ROOT}/keys" \
    --password "${ROOT}/password.txt" \
    --unlock "${UNLOCK_ACCOUNT}" \
    --verbosity 2 --mine \
    --ws --wsapi eth,net,web3,personal --wsport $WSPORT \
    --rpc --rpcapi eth,net,web3,personal,miner --rpcaddr 0.0.0.0 --rpcport $RPCPORT \
    --targetgaslimit 6500000 < /dev/null > $ROOT/geth.log 2>&1 &
  NODE_PID=$!

  tail -F $ROOT/geth.log 2>/dev/null &
  TAIL_PID=$!
}

start

