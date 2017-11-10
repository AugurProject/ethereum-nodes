FROM ubuntu:16.04
# install all dependencies
RUN apt-get update \
	&& apt-get install --yes --no-install-recommends curl python3 python3-pip python3-setuptools pkg-config python3-dev autoconf automake libtool libssl-dev make g++ jq \
	&& rm -rf /var/lib/apt/lists/*

RUN pip3 install wheel
RUN pip3 install ethereum==2.0.4 ethereum-abi-utils==0.4.0 ethereum-utils==0.4.0 pysha3==1.0.2 ecdsa==0.13 web3==3.11.1 py-solc==1.0.1 rlp==0.5.1

ADD . /scripts
WORKDIR /scripts

RUN pip3 install -r /scripts/requirements.txt

ENV PYTHONUNBUFFERED 1

ENTRYPOINT /usr/bin/python3 /scripts/spam-villa.py
