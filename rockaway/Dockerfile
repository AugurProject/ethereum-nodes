FROM ethereum/client-go:latest
ARG mode
ARG name
ARG genesis_file=genesis.json

RUN apk update \
    && apk add bash curl jq

COPY ${genesis_file} /geth/genesis.json
RUN geth --datadir /geth/chain --keystore /geth/keys init /geth/genesis.json
ENV ETHEREUM_MODE=${mode}
ENV ETHEREUM_NODE_NAME=${name}

WORKDIR /
COPY start.sh /start.sh
RUN chmod +x /start.sh
ENTRYPOINT [ "/start.sh" ]

# docker image build --tag geth-dev-node .
# docker container run --rm -it -p 8545:8545 --name geth-dev-node geth-dev-node
#-p 8545:8545 ethereum/client-go --dev --ws --wsapi eth,net,web3,personal --wsport 8546 --rpc --rpcapi eth,net,web3,personal,miner --rpcaddr 0.0.0.0 --targetgaslimit 7500000
# To connect in a separate terminal: geth attach http://127.0.0.1:8545
