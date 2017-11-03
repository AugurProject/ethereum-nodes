docker run --name ethereum -d -ti -p 80:8180 -p 8545:8545 -p 8546:8546 -p 30303:30303 -p 30303:30303/udp \
  parity/parity:v1.8.0 \
    --chain kovan \
    --ui-hosts kovan.augur.net,localhost \
    --ui-interface all \
    --ws-interface all \
    --ws-apis web3,eth,net,personal \
    --ws-origins all \
    --jsonrpc-interface all \
    --jsonrpc-apis web3,eth,net,personal \
    --jsonrpc-cors "*"
