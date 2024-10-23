# BTC RPC Explorer Instructions

Welcome to the BTC RPC Explorer! This guide will help you set up and use the service easily.

## What You Need

- A running instance of **Bitcoin Core** (version >= 26.0.0 and < 29.0.0).
- Configure your Bitcoin Core to allow RPC access.

## Bitcoin Core Setup

Make sure your `bitcoin.conf` file includes these lines:

```plaintext
server=1
rpcuser=<your_rpc_username>
rpcpassword=<your_rpc_password>
rpcallowip=127.0.0.1
