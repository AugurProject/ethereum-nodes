docker run --name ethereum -d -ti --rm \
  -p 80:8180 -p 8545:8545 -p 8546:8546 -p 30303:30303 -p 30303:30303/udp \
  -v /root/.local:/root/.local \
  parity/parity:v1.8.0 \
    --chain kovan \
    --public-node \
    --ui-hosts kovan.augur.net,localhost \
    --ui-interface all \
    --ws-interface all \
    --ws-apis web3,eth,net,personal,parity \
    --ws-origins all \
    --jsonrpc-interface all \
    --jsonrpc-apis web3,eth,net,personal,parity \
    --jsonrpc-cors "*"
