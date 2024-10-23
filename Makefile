# Define package ID and version
PKG_ID := $(shell yq e ".id" manifest.yaml)
PKG_VERSION := $(shell yq e ".version" manifest.yaml)

# Gather TypeScript files (if applicable)
TS_FILES := $(shell find ./ -name '*.ts')

.DELETE_ON_ERROR:

all: verify

verify: $(PKG_ID).s9pk
	@echo "Verifying package..."
	@start-sdk verify s9pk $(PKG_ID).s9pk
	@echo "Verification completed."

install: $(PKG_ID).s9pk
	@echo "Installing package..."
	@start-cli package install $(PKG_ID).s9pk
	@echo "Installation completed."

clean:
	@echo "Cleaning up previous build artifacts..."
	rm -rf docker-images
	rm -f $(PKG_ID).s9pk
	@echo "Cleanup completed."

# Docker image for x86_64
docker-images/x86_64.tar: Dockerfile docker_entrypoint.sh
	@echo "Building x86_64 Docker image..."
	mkdir -p docker-images
	docker buildx build --tag start9/$(PKG_ID)/main:$(PKG_VERSION) --platform=linux/amd64 -o type=docker,dest=docker-images/x86_64.tar .
	@echo "x86_64 Docker image built successfully."

# Docker image for aarch64
docker-images/aarch64.tar: Dockerfile docker_entrypoint.sh
	@echo "Building aarch64 Docker image..."
	mkdir -p docker-images
	docker buildx build --tag start9/$(PKG_ID)/main:$(PKG_VERSION) --platform=linux/arm64 -o type=docker,dest=docker-images/aarch64.tar .
	@echo "aarch64 Docker image built successfully."

$(PKG_ID).s9pk: manifest.yaml instructions.md LICENSE icon.png docker-images/aarch64.tar docker-images/x86_64.tar .env scripts/get-config.sh config-spec.yaml scripts/set-config.sh scripts/start.sh
	@echo "Packing the service..."
	@start-sdk pack
	@echo "Service packed successfully into $(PKG_ID).s9pk."
