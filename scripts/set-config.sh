#!/bin/bash

# Update the environment variables based on the new config file
echo "Updating configuration..."

if [[ -f /var/www/html/.env ]]; then
    source /var/www/html/.env
else
    echo "No .env file found!"
    exit 1
fi

# Print out the configuration to verify
echo "Current Configuration:"
echo "BTCEXP_HOST: $BTCEXP_HOST"
echo "CORE_RPC_USER: $CORE_RPC_USER"
echo "CORE_RPC_PASSWORD: $CORE_RPC_PASSWORD"
echo "CORE_RPC_HOST: $CORE_RPC_HOST"
echo "CORE_RPC_PORT: $CORE_RPC_PORT"
