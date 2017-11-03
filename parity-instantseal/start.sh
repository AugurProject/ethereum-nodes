#!/bin/bash

RPCPORT=8545
WSPORT=8546
if [[ "${ROOT}" = "" ]] ; then ROOT="/geth" ; fi
if [[ "${UNLOCK_ACCOUNT}" = "" ]] ; then UNLOCK_ACCOUNT="0xc5ed899b0878656feb06467e2e9ede3ae73cbcb7" ; fi

source ../common_start.sh

node_start() {
  # launch parity in the background
  if [[ ( -z "$1" ) || ( "$1" == "0" ) ]]; then
    /parity/parity --config /parity/instant-seal-config.toml --gasprice 1 &
  else
    sed -i '/stepDuration/s/1/'${1}'/' /parity/aura-chain-spec.json
    /parity/parity --config /parity/aura-config.toml --gasprice 1 &
  fi

  NODE_PID = $!
}

start()
