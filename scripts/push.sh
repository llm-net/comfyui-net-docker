#!/bin/bash

# ComfyUI Docker Push Script
# Usage: ./push.sh [version] [type]
# Example: ./push.sh v0.3.7 base
#          ./push.sh v0.3.7 extend
#          ./push.sh v0.3.7 all

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
PUSH_TYPE=$2

# Validate push type
if [[ ! "$PUSH_TYPE" =~ ^(base|extend|all)$ ]]; then
    print_error "Invalid push type. Use 'base', 'extend', or 'all'"
    exit 1
fi

# Check Docker login status
check_docker_login() {
    if ! docker info 2>/dev/null | grep -q "Username:"; then
        print_error "Not logged in to Docker Hub. Please run 'docker login' first."
        exit 1
    fi
}

# Push base image
push_base() {
    print_info "Pushing base image for ComfyUI ${VERSION}..."
    
    # Push version tag
    docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}
    if [ $? -eq 0 ]; then
        print_success "Pushed ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}"
    else
        print_error "Failed to push ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}"
        exit 1
    fi
    
    # Push latest tag
    docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:latest
    if [ $? -eq 0 ]; then
        print_success "Pushed ${DOCKER_USERNAME}/${IMAGE_NAME}:latest"
    else
        print_error "Failed to push ${DOCKER_USERNAME}/${IMAGE_NAME}:latest"
        exit 1
    fi
}

# Push extend image
push_extend() {
    print_info "Pushing extended image for ComfyUI ${VERSION}..."
    
    # Push version-extend tag
    docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}-extend
    if [ $? -eq 0 ]; then
        print_success "Pushed ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}-extend"
    else
        print_error "Failed to push ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}-extend"
        exit 1
    fi
    
    # Push latest-extend tag
    docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:latest-extend
    if [ $? -eq 0 ]; then
        print_success "Pushed ${DOCKER_USERNAME}/${IMAGE_NAME}:latest-extend"
    else
        print_error "Failed to push ${DOCKER_USERNAME}/${IMAGE_NAME}:latest-extend"
        exit 1
    fi
}

# Main push logic
print_info "Starting push process..."
print_info "Registry: ${DOCKER_REGISTRY}"
print_info "Username: ${DOCKER_USERNAME}"
print_info "Version: ${VERSION}"
print_info "Push Type: ${PUSH_TYPE}"

# Check login status
check_docker_login

case $PUSH_TYPE in
    base)
        push_base
        ;;
    extend)
        push_extend
        ;;
    all)
        push_base
        push_extend
        ;;
esac

print_success "Push process completed!"

# Update versions.json
print_info "Updating versions.json..."
python3 scripts/update_versions.py ${VERSION}