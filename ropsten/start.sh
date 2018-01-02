#!/bin/bash

docker run -d -p 8545:8545 -p 8546:8546 -p 30303:30303 -it -v /root/geth-ropsten:/root/.ethereum ethereum/client-go --fast --testnet --cache 16 --wsorigins '*' --ws --wsapi eth,net,web3,personal,txpool --wsport 8546 --wsaddr 0.0.0.0 --rpc --rpcapi eth,net,web3,personal,txpool --rpcaddr 0.0.0.0 --maxpeers 128
