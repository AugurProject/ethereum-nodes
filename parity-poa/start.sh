#!/bin/bash

RPCPORT=8545
WSPORT=8546

source ./common_start.sh

node_start() {
  # launch parity in the background
  /bin/parity --config /home/parity/aura-config.toml &
  NODE_PID=$!
}

start
