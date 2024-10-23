# Build stage
FROM node:20-bookworm-slim AS builder

# Install necessary build dependencies including Python
RUN apt-get update -qqy && \
    apt-get upgrade -qqy && \
    DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends \
    build-essential \
    ca-certificates \
    git \
    curl \
    python3 \
    python3-pip && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Set the working directory
WORKDIR /build

# Clone the BTC RPC Explorer repository
RUN git clone https://github.com/janoside/btc-rpc-explorer .

# Install the necessary dependencies
RUN npm install

# Remove the build step
# RUN npm run build  # This line is commented out

# Final stage
FROM debian:bookworm-slim AS final

# Install runtime dependencies
RUN apt-get update -qqy && \
    apt-get upgrade -qqy && \
    DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends \
    bash \
    curl \
    tini \
    netcat-openbsd \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Install yq for YAML processing
ARG PLATFORM
RUN curl -sLo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${PLATFORM} && chmod +x /usr/local/bin/yq

# Copy the built application from the builder stage
COPY --from=builder /build /var/www/html

# Copy the entrypoint script and the get-config.sh script
COPY docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
COPY scripts/get-config.sh /usr/local/bin/get-config.sh

RUN chmod +x /usr/local/bin/docker_entrypoint.sh /usr/local/bin/get-config.sh

# Copy the .env file
COPY .env /btc-rpc-explorer-data/.env

# Copy configuration scripts
COPY scripts/get-config.sh /usr/local/bin/get-config.sh
COPY scripts/set-config.sh /usr/local/bin/set-config.sh

# Ensure scripts are executable
RUN chmod +x /usr/local/bin/get-config.sh \
    && chmod +x /usr/local/bin/set-config.sh

# Set the working directory
WORKDIR /var/www/html

# Expose necessary ports
EXPOSE 3000

# Set the stop signal for graceful shutdown
STOPSIGNAL SIGINT

# Set the entrypoint for the container
ENTRYPOINT ["docker_entrypoint.sh"]
