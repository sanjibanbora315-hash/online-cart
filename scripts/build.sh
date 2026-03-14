#!/bin/bash

# Online Cart - Build Script
# Usage: ./scripts/build.sh [options]
# Options:
#   --skip-tests    Skip running tests
#   --docker        Build Docker images

set -e

SKIP_TESTS=""
BUILD_DOCKER=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-tests)
            SKIP_TESTS="-DskipTests"
            shift
            ;;
        --docker)
            BUILD_DOCKER=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "=========================================="
echo "  Online Cart - Build Script"
echo "=========================================="

# Build Maven projects
echo ""
echo "[1/2] Building Maven projects..."
mvn clean package $SKIP_TESTS

if [ "$BUILD_DOCKER" = true ]; then
    echo ""
    echo "[2/2] Building Docker images..."

    services=("config-server" "discovery-server" "api-gateway" "user-service" "product-service" "order-service")

    for service in "${services[@]}"; do
        echo "Building Docker image for $service..."
        docker build -t online-cart/$service:latest ./$service
    done

    echo ""
    echo "Docker images built successfully!"
    docker images | grep online-cart
fi

echo ""
echo "=========================================="
echo "  Build completed successfully!"
echo "=========================================="
