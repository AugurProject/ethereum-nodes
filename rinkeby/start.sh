#!/bin/bash

docker run -d -p 8545:8545 -p 8546:8546 -p 30303:30303 -it \
  -v /root/rinkeby:/root/.ethereum ethereum/client-go \
  --fast --rinkeby --cache 16  \
  --wsorigins ‘*’ --ws --wsapi eth,net,web3,personal --wsport 8546 --wsaddr 0.0.0.0 \
  --rpc --rpcapi eth,net,web3,personal --rpcaddr 0.0.0.0 --maxpeers 128

