#!/bin/bash
docker image build --tag augur/rockaway-geth-node:latest -f Dockerfile .
docker image build --tag augur/rockaway-bootnode:latest -f bootnode/Dockerfile .
docker image build --tag augur/rockaway-sealer:latest -f sealer/Dockerfile .
