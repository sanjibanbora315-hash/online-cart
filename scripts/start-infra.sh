#!/bin/bash

# Online Cart - Start Infrastructure Services
# This script starts all infrastructure services (MySQL, Redis, Kafka, ELK, Mailpit)

set -e

echo "=========================================="
echo "  Starting Infrastructure Services"
echo "=========================================="

# Start infrastructure services only
docker-compose up -d mysql redis zookeeper kafka kafka-ui mailpit elasticsearch logstash kibana

echo ""
echo "Waiting for services to be healthy..."
sleep 10

echo ""
echo "=========================================="
echo "  Infrastructure Services Status"
echo "=========================================="
docker-compose ps

echo ""
echo "=========================================="
echo "  Service URLs"
echo "=========================================="
echo "  MySQL:          localhost:3306"
echo "  Redis:          localhost:6379"
echo "  Kafka:          localhost:29092"
echo "  Kafka UI:       http://localhost:8090"
echo "  Mailpit UI:     http://localhost:8025"
echo "  Elasticsearch:  http://localhost:9200"
echo "  Kibana:         http://localhost:5601"
echo "=========================================="
