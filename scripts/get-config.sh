#!/bin/bash

# Set default values using your actual RPC credentials
RPC_USER="bitcoin"           # Your RPC username
RPC_PASS="wjtnbdojq6pyyg21ubi7"  # Your RPC password
RPC_HOST="127.0.0.1"        # Change this if your Bitcoin Core is hosted elsewhere
RPC_PORT="8332"             # Default Bitcoin Core RPC port

# Output the configuration as environment variables
cat <<EOL
export CORE_RPC_HOST=$RPC_HOST
export CORE_RPC_USERNAME=$RPC_USER
export CORE_RPC_PASSWORD=$RPC_PASS
export CORE_RPC_PORT=$RPC_PORT
EOL
