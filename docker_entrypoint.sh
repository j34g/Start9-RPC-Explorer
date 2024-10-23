#!/bin/bash

set -ea

echo
echo "Starting BTC RPC Explorer..."
echo

# Load configuration from the config.yaml file
export BITCOIN_RPC_USER=$(yq e '.bitcoind.user' /btc-rpc-explorer-data/start9/config.yaml)
export BITCOIN_RPC_PASSWORD=$(yq e '.bitcoind.password' /btc-rpc-explorer-data/start9/config.yaml)
export BITCOIN_RPC_TIMEOUT=$(yq e '.rpc-timeout' /btc-rpc-explorer-data/start9/config.yaml)
export API_PORT=3000  # Adjust the port as needed

# Determine the network (mainnet/testnet)
NETWORK=$(yq e '.bitcoind.type' /btc-rpc-explorer-data/start9/config.yaml)
case "$NETWORK" in
"mainnet")
    export BITCOIN_RPC_URL=http://bitcoind.embassy
    export BITCOIN_RPC_PORT=8332
    echo "Configured BTC RPC Explorer for mainnet: $BITCOIN_RPC_URL:$BITCOIN_RPC_PORT"
    ;;
"testnet")
    export BITCOIN_RPC_URL=http://bitcoind-testnet.embassy
    export BITCOIN_RPC_PORT=48332
    echo "Configured BTC RPC Explorer for testnet: $BITCOIN_RPC_URL:$BITCOIN_RPC_PORT"
    ;;
*)
    echo "Unknown Bitcoin Core node type. Exiting."
    exit 1
    ;;
esac

# Start Bitcoin Core in the background
bitcoind -datadir=/data &

# Start the BTC RPC Explorer
cd /app  # Ensure this is the directory where BTC RPC Explorer is located
npm start &  # Start the application in the background
app_process=$!

# Handle process management
_term() {
    echo "Caught TERM signal!"
    kill -TERM "$app_process" 2>/dev/null
}

trap _term TERM

# Wait for the application to exit
wait "$app_process"
