#!/bin/bash

# Online Cart - Stop All Services

echo "=========================================="
echo "  Stopping All Services"
echo "=========================================="

docker-compose down

echo ""
echo "All services stopped."
