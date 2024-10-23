#!/bin/bash

# Ensure configuration is set before starting
if [[ ! -f /var/www/html/.env ]]; then
    echo ".env file not found! Please run get-config.sh first."
    exit 1
fi

# Start the BTC RPC Explorer
node /var/www/html/bin/www
