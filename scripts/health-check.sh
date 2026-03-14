#!/bin/bash

# Online Cart - Health Check Script
# Checks the health of all services

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Service endpoints
declare -A SERVICES=(
    ["Config Server"]="http://localhost:8888/actuator/health"
    ["Discovery Server"]="http://localhost:8761/actuator/health"
    ["API Gateway"]="http://localhost:8080/actuator/health"
    ["User Service"]="http://localhost:8081/actuator/health"
    ["Product Service"]="http://localhost:8082/actuator/health"
    ["Order Service"]="http://localhost:8083/actuator/health"
)

# Infrastructure endpoints
declare -A INFRASTRUCTURE=(
    ["MySQL"]="localhost:3306"
    ["Redis"]="localhost:6379"
    ["Kafka"]="localhost:29092"
    ["Elasticsearch"]="http://localhost:9200/_cluster/health"
    ["Kibana"]="http://localhost:5601/api/status"
)

echo "=========================================="
echo "  Online Cart - Health Check"
echo "=========================================="
echo ""

# Check microservices
echo "Microservices:"
echo "--------------"

for service in "${!SERVICES[@]}"; do
    url="${SERVICES[$service]}"
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")

    if [ "$response" == "200" ]; then
        echo -e "  ${GREEN}✓${NC} $service: UP"
    else
        echo -e "  ${RED}✗${NC} $service: DOWN (HTTP $response)"
    fi
done

echo ""
echo "Infrastructure:"
echo "---------------"

# Check MySQL
if nc -z localhost 3306 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} MySQL: UP"
else
    echo -e "  ${RED}✗${NC} MySQL: DOWN"
fi

# Check Redis
if nc -z localhost 6379 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Redis: UP"
else
    echo -e "  ${RED}✗${NC} Redis: DOWN"
fi

# Check Kafka
if nc -z localhost 29092 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Kafka: UP"
else
    echo -e "  ${RED}✗${NC} Kafka: DOWN"
fi

# Check Elasticsearch
es_response=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:9200/_cluster/health" 2>/dev/null || echo "000")
if [ "$es_response" == "200" ]; then
    echo -e "  ${GREEN}✓${NC} Elasticsearch: UP"
else
    echo -e "  ${RED}✗${NC} Elasticsearch: DOWN"
fi

# Check Kibana
kibana_response=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:5601/api/status" 2>/dev/null || echo "000")
if [ "$kibana_response" == "200" ]; then
    echo -e "  ${GREEN}✓${NC} Kibana: UP"
else
    echo -e "  ${RED}✗${NC} Kibana: DOWN"
fi

# Check Mailpit
mailpit_response=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8025" 2>/dev/null || echo "000")
if [ "$mailpit_response" == "200" ]; then
    echo -e "  ${GREEN}✓${NC} Mailpit: UP"
else
    echo -e "  ${RED}✗${NC} Mailpit: DOWN"
fi

echo ""
echo "=========================================="

# Check Eureka registered services
echo ""
echo "Registered Services (Eureka):"
echo "-----------------------------"
eureka_apps=$(curl -s -H "Accept: application/json" "http://localhost:8761/eureka/apps" 2>/dev/null || echo "{}")

if echo "$eureka_apps" | grep -q "application"; then
    echo "$eureka_apps" | grep -o '"name":"[^"]*"' | sed 's/"name":"//g' | sed 's/"//g' | while read app; do
        echo -e "  ${GREEN}✓${NC} $app"
    done
else
    echo -e "  ${YELLOW}!${NC} No services registered or Eureka unavailable"
fi

echo ""
echo "=========================================="
