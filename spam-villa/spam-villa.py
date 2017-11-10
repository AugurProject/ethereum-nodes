#!/usr/bin/env python
import os
import rlp
from ethereum.transactions import Transaction
from web3 import Web3, KeepAliveRPCProvider
from ethereum.utils import coerce_addr_to_hex, privtoaddr
from time import sleep

TX_BASE_GAS_PRICE = os.environ.get('TX_BASE_GAS_PRICE', 1 * 10 ** 9)
TX_MIN_PENDING_COUNT = os.environ.get('TX_MIN_PENDING_COUNT', 6)

ETHEREUM_TARGET_BLOCK_GAS_LIMIT = os.environ.get('ETHEREUM_TARGET_BLOCK_GAS_LIMIT', 6700000)

# 6 hard coded gas sizes
TX_GAS_RATIO_AND_PRICE = [
    [0.95, TX_BASE_GAS_PRICE + 5],
    [0.67, TX_BASE_GAS_PRICE + 4],
    [0.446, TX_BASE_GAS_PRICE + 3],
    [0.297, TX_BASE_GAS_PRICE + 2],
    [0.198, TX_BASE_GAS_PRICE + 1],
    [0.132, TX_BASE_GAS_PRICE + 0]
]

ETHEREUM_NODE_HOST = os.environ.get('ETHEREUM_NODE_HOST', 'ethereum-node')
ETHEREUM_NODE_PORT = int(os.environ.get('ETHEREUM_NODE_PORT', 8545))
RPC_INFO = {'host': ETHEREUM_NODE_HOST, 'port': ETHEREUM_NODE_PORT}
web3 = Web3(KeepAliveRPCProvider(**RPC_INFO))

THROW_CONTRACTS={
    3: '0x675828c833a33c6f808adcc6e08e397c8da855ac', # ropsten
    4: '0xffc4700dc5ac0639525ab50ab0a84ac125599f33', # rinkeby
}

CONTRACT_THROW_ADDRESS = os.environ.get('ETHEREUM_THROW_CONTRACT', THROW_CONTRACTS[web3.admin.nodeInfo['protocols']['eth']['network']])
PRIVATE_KEYS = os.environ['ETHEREUM_PRIVATE_KEYS']


def get_pending_tx_counts(web3):
    return {
        sender.lower(): [
            len(transactions),
            max([int(nonce) for nonce in transactions.keys()])
        ]
        for sender, transactions
        in web3._requestManager.request_blocking("txpool_inspect", [])["pending"].items()
    }

def get_block_gas_limit(web3):
    return web3.eth.getBlock('latest').gasLimit

def update_block_gas_limits(block_gas_limit, accountHolders):
    [accountHolder.update_block_gas_limit(block_gas_limit) for accountHolder in accountHolders]

class AccountHolder():
    def __init__(self, web3, private_key, gas_limit_percentage, gas_price):
        self.web3 = web3
        self.private_key = private_key
        self.address = "0x%s" % coerce_addr_to_hex(privtoaddr(private_key))
        self.gas_limit_percentage = gas_limit_percentage
        self.gas_price = gas_price

    def update_block_gas_limit(self, block_gas_limit):
        self.block_gas_limit = block_gas_limit

    def fill_pending_queue(self, current_pending_tx_count, next_nonce):
        tx_to_send = TX_MIN_PENDING_COUNT - current_pending_tx_count
        return ([self.send_tx(nonce)
                 for nonce in range(next_nonce, next_nonce + tx_to_send)])

    def send_tx(self, nonce):
        tx = Transaction(nonce,
                         gasprice=self.gas_price,
                         startgas=int(self.block_gas_limit * self.gas_limit_percentage),
                         to=CONTRACT_THROW_ADDRESS,
                         value=0,
                         data='',
                         )

        tx.sign(self.private_key)
        raw_tx = rlp.encode(tx)
        raw_tx_hex = self.web3.toHex(raw_tx)

        try:
            tx_id = web3.eth.sendRawTransaction(raw_tx_hex)
        except Exception as e:
            print("Something went wrong with tx for %s" % self.address)
            print(e)
            return None

        return tx_id


account_holders = [AccountHolder(web3, private_key, *TX_GAS_RATIO_AND_PRICE[index])
                   for index, private_key in enumerate(PRIVATE_KEYS.split(","))]

print("Using the following accounts:")
print("\n".join([account_holder.address for account_holder in account_holders]))

if __name__ == "__main__":
    while True:
        pending_tx_counts = get_pending_tx_counts(web3)
        block_gas_limit = get_block_gas_limit(web3)
        if block_gas_limit < ETHEREUM_TARGET_BLOCK_GAS_LIMIT:
            update_block_gas_limits(block_gas_limit, account_holders)
            for account_holder in account_holders:
                if account_holder.address in pending_tx_counts:
                    tx_count, highest_nonce = pending_tx_counts[account_holder.address]
                    next_nonce = highest_nonce + 1
                else:
                    tx_count = 0
                    next_nonce = web3.eth.getTransactionCount(account_holder.address)

                if tx_count < TX_MIN_PENDING_COUNT:
                    [print("%s sent TX: %s" % (account_holder.address, tx_hash))
                     for tx_hash in account_holder.fill_pending_queue(tx_count, next_nonce)]

        sleep(1)