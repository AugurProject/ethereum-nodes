#!/bin/bash

WSPORT=8456
ROOT=/geth
UNLOCK_ACCOUNTS="0xc5ed899b0878656feb06467e2e9ede3ae73cbcb7"

# make it so we can do job control inside the script (fg at the end)
set -m

# geth is dumb and won't let us run it in the background, and nohup redirects to file when run in a script
tail -F nohup.out &

nohup geth \
  --datadir "${ROOT}/chain" \
  --keystore "${ROOT}/keys" \
  --password "${ROOT}/password.txt" \
  --unlock "${UNLOCK_ACCOUNTS}"
  --verbosity 2 --mine \
  --ws --wsapi eth,net,web3,personal --wsport $WSPORT \
  --rpc --rpcapi eth,net,web3,personal,miner --rpcaddr 0.0.0.0 \
  --targetgaslimit 6500000 &

# spin until node is connectable
while ! nc -w 1 -q 1 localhost $WSPORT < /dev/null; do sleep 1; done

read -r -d INITIAL_TX_DATA << 'EOF'
{
  "jsonrpc":"2.0",
  "method":"eth_sendTransaction",
  "params": [{
    "value": "0x0",
    "to":"0x0000000000000000000000000000000000000000",
    "from":"0xc5ed899b0878656feb06467e2e9ede3ae73cbcb7",
    "data":"0x",
    "gasPrice":"0x1"
  }],
  "id": 1
}
EOF

if curl  --silent --show-error localhost:$WSPORT -X POST -H "Content-Type: application/json" --data "${INITIAL_TX_DATA}" ; then
  # bring geth to the foreground
  fg
else
  echo "Could not communicate with GETH, returned error ${?}"
fi

