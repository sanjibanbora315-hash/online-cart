#!/bin/bash

# Online Cart - Kubernetes Deployment Script

set -e

echo "=========================================="
echo "  Deploying to Kubernetes"
echo "=========================================="

# Create namespace
echo "[1/5] Creating namespace..."
kubectl apply -f k8s/namespace.yml

# Apply base configurations
echo "[2/5] Applying configurations..."
kubectl apply -f k8s/base/configmap.yml
kubectl apply -f k8s/base/secrets.yml

# Deploy infrastructure
echo "[3/5] Deploying infrastructure..."
kubectl apply -f k8s/base/mysql.yml
kubectl apply -f k8s/base/redis.yml
kubectl apply -f k8s/base/kafka.yml

echo "Waiting for infrastructure to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql -n online-cart --timeout=120s
kubectl wait --for=condition=ready pod -l app=redis -n online-cart --timeout=60s

# Deploy microservices
echo "[4/5] Deploying microservices..."
kubectl apply -f k8s/services/config-server.yml
sleep 30
kubectl apply -f k8s/services/discovery-server.yml
sleep 30
kubectl apply -f k8s/services/api-gateway.yml
kubectl apply -f k8s/services/user-service.yml
kubectl apply -f k8s/services/product-service.yml
kubectl apply -f k8s/services/order-service.yml

# Check status
echo "[5/5] Checking deployment status..."
kubectl get pods -n online-cart

echo ""
echo "=========================================="
echo "  Deployment Complete!"
echo "=========================================="
echo "Run 'kubectl get svc -n online-cart' to see service endpoints"
