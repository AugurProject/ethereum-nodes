#!/bin/bash

# Expects an init'd node in the /geth directory using
# our defined genesis

networkId=$(jq ".config.chainId" /geth/genesis.json)

bootnode() {
  if [[ "${ETHEREUM_NODE_NAME}x" == "x" ]]; then
    ETHEREUM_NODE_NAME="Rockaway Node ${ETHEREUM_MODE}"
  fi

  echo $ETHEREUM_NODEKEY_HEX > /geth/node.key

  bootnode --nodekey /geth/node.key --datadir /geth
}

sealer() {
  if [[ "${ETHEREUM_NODE_NAME}x" == "x" ]]; then
    ETHEREUM_NODE_NAME="Rockaway Node ${ETHEREUM_MODE}"
  fi

  geth \
    --networkid ${networkId} \
    --cache 512 \
    --maxpeers 512 \
    --lightpeers 256 \
    --lightserv 50 \
    --ethstats "${ETHEREUM_NODE_NAME}:${ETHEREUM_ETHSTATS_PASSWORD}:${ETHEREUM_ETHSTATS_SERVER}"
}

# Some default
if [[ "${ETHEREUM_MODE}" != "bootnode" ]]; then
  export ETHEREUM_MODE="sealer"
  if [[ "${ETHEREUM_UNLOCK_ACCOUNT}" == "x" ]]; then
    echo "Sealer nodes must be given an unlock account"
  fi
  sealer
else
  # Boot node! Require a ETHEREUM_NODEKEY_HEX
  if [[ "${ETHEREUM_NODEKEY_HEX}x" == "x" ]]; then
    echo "Must have a node key"
    exit 1
  fi
  bootnode
fi

