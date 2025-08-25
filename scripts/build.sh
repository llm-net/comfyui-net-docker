#!/bin/bash

# ComfyUI Docker Build Script
# Usage: ./build.sh [version] [type]
# Example: ./build.sh v0.3.7 base
#          ./build.sh v0.3.7 extend
#          ./build.sh v0.3.7 all

set -e

# Configuration
DOCKER_REGISTRY=${DOCKER_REGISTRY:-"docker.io"}
DOCKER_USERNAME=${DOCKER_USERNAME:-"llmnet"}
IMAGE_NAME="comfyui-net"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Check arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <version> <type>"
    echo "  version: ComfyUI version (e.g., v0.3.7)"
    echo "  type: base, extend, or all"
    exit 1
fi

VERSION=$1
BUILD_TYPE=$2

# Validate build type
if [[ ! "$BUILD_TYPE" =~ ^(base|extend|all)$ ]]; then
    print_error "Invalid build type. Use 'base', 'extend', or 'all'"
    exit 1
fi

# Build base image
build_base() {
    print_info "Building base image for ComfyUI ${VERSION}..."
    
    docker build \
        --build-arg COMFYUI_VERSION=${VERSION} \
        -t ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION} \
        -t ${DOCKER_USERNAME}/${IMAGE_NAME}:latest \
        -f dockerfiles/base/Dockerfile \
        .
    
    if [ $? -eq 0 ]; then
        print_success "Base image built successfully"
    else
        print_error "Failed to build base image"
        exit 1
    fi
}

# Build extend image
build_extend() {
    print_info "Building extended image for ComfyUI ${VERSION}..."
    
    docker build \
        --build-arg COMFYUI_VERSION=${VERSION} \
        -t ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}-extend \
        -t ${DOCKER_USERNAME}/${IMAGE_NAME}:latest-extend \
        -f dockerfiles/extend/Dockerfile \
        .
    
    if [ $? -eq 0 ]; then
        print_success "Extended image built successfully"
    else
        print_error "Failed to build extended image"
        exit 1
    fi
}

# Main build logic
print_info "Starting build process..."
print_info "Registry: ${DOCKER_REGISTRY}"
print_info "Username: ${DOCKER_USERNAME}"
print_info "Version: ${VERSION}"
print_info "Build Type: ${BUILD_TYPE}"

case $BUILD_TYPE in
    base)
        build_base
        ;;
    extend)
        build_extend
        ;;
    all)
        build_base
        build_extend
        ;;
esac

print_success "Build process completed!"

# List built images
echo ""
print_info "Built images:"
docker images | grep "${DOCKER_USERNAME}/${IMAGE_NAME}" | grep -E "${VERSION}|latest"