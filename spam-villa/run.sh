#!/bin/bash

KEYS=$(paste -sd, testnet-keys.txt)


# Optional: -e ETHEREUM_THROW_CONTRACT=0xffc4700dc5ac0639525ab50ab0a84ac125599f33
# Uses hardcoded values per network-id if missing
# KEYS is a comma-separated list of 6 private keys

docker run -t -e ETHEREUM_PRIVATE_KEYS=$KEYS -e ETHEREUM_NODE_HOST=127.0.0.1 augur/spam-villa
