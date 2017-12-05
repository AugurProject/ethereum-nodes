#!/bin/bash

RPCPORT=8545
WSPORT=8546
if [[ "${ROOT}" = "" ]] ; then ROOT="/geth" ; fi
if [[ "${UNLOCK_ACCOUNT}" = "" ]] ; then UNLOCK_ACCOUNT="0x913da4198e6be1d5f5e4a40d0667f70c0b5430eb" ; fi

source ./common_start.sh

node_start() {
  # launch parity in the background
  /parity/parity --config /parity/aura-config.toml --gasprice 1 &
  NODE_PID=$!
}

start
