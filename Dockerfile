# Build stage
FROM node:20-bookworm-slim AS build

# Bitcoin Core version
ARG BITCOIN_CORE_VERSION=24.0.1
# Working directory for building
WORKDIR /build

# Install necessary packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential ca-certificates curl git python3 wget && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Bitcoin Core
RUN curl -sSL https://bitcoin.org/bin/bitcoin-core-${BITCOIN_CORE_VERSION}/bitcoin-${BITCOIN_CORE_VERSION}-x86_64-linux-gnu.tar.gz | tar -xz -C /usr/local --strip-components=1

# Create application directory
RUN mkdir /app

# Set the working directory for the app
WORKDIR /app

# Copy package.json and install dependencies
COPY btc-rpc-explorer/package*.json ./
RUN npm install

# Copy the rest of the application files
COPY btc-rpc-explorer/ ./

# Expose necessary ports
EXPOSE 3000

# Build stage for final output
FROM node:20-bookworm-slim

# Set environment
ENV NODE_ENV=production

# Install Nginx (if necessary, otherwise can be omitted)
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends nginx && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy Bitcoin Core binaries
COPY --from=build /usr/local/bin/bitcoin* /usr/local/bin/
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist  # Assuming there's a dist folder after build

# Set working directory
WORKDIR /app

# Copy entrypoint script
COPY docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh

# Set the command to run the application
CMD ["npm", "start"]
