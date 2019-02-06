FROM parity/parity:v2.3.2

USER root

# install all dependencies
RUN apt-get update \
	&& apt-get install --yes --no-install-recommends curl \
	&& rm -rf /var/lib/apt/lists/*

COPY ./common_start.sh /common_start.sh
COPY start.sh /start.sh
RUN chmod +x /start.sh


WORKDIR /
COPY dev-key.json /home/parity/keys/AuraChain/dev-key.json
COPY aura-chain-spec.json /home/parity/aura-chain-spec.json
COPY aura-config.toml /home/parity/aura-config.toml
RUN echo "" > /home/parity/password

RUN chown -R parity /home/parity

ENTRYPOINT [ "/start.sh" ]

USER parity

# docker image build --tag parity-dev-node .
# docker container run --rm -it -p 8000:8000 -p 8001:8001 -p 8545:8545 -p 8180:8180 --name parity-dev-node parity-dev-node
