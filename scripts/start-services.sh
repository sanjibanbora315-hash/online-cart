#!/bin/bash

# Online Cart - Start Microservices
# This script starts all microservices in the correct order

set -e

echo "=========================================="
echo "  Starting Online Cart Microservices"
echo "=========================================="

# Check if infrastructure is running
if ! docker-compose ps mysql | grep -q "Up"; then
    echo "Infrastructure services are not running. Starting them first..."
    ./scripts/start-infra.sh
    sleep 15
fi

echo ""
echo "[1/6] Starting Config Server..."
docker-compose up -d config-server
echo "Waiting for Config Server to be ready..."
sleep 20

echo ""
echo "[2/6] Starting Discovery Server..."
docker-compose up -d discovery-server
echo "Waiting for Discovery Server to be ready..."
sleep 20

echo ""
echo "[3/6] Starting API Gateway..."
docker-compose up -d api-gateway
sleep 10

echo ""
echo "[4/6] Starting User Service..."
docker-compose up -d user-service
sleep 5

echo ""
echo "[5/6] Starting Product Service..."
docker-compose up -d product-service
sleep 5

echo ""
echo "[6/6] Starting Order Service..."
docker-compose up -d order-service
sleep 5

echo ""
echo "=========================================="
echo "  All Services Started!"
echo "=========================================="
docker-compose ps

echo ""
echo "=========================================="
echo "  Service URLs"
echo "=========================================="
echo "  API Gateway:    http://localhost:8080"
echo "  Eureka:         http://localhost:8761"
echo "  Config Server:  http://localhost:8888"
echo "=========================================="
