#!/bin/bash

# Online Cart - Test Runner Script
# Runs various tests for the project

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_usage() {
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  unit          Run unit tests for all services"
    echo "  integration   Run integration tests (requires services running)"
    echo "  health        Run health checks"
    echo "  load          Run K6 load tests"
    echo "  stress        Run K6 stress tests"
    echo "  all           Run all tests"
    echo "  help          Show this help message"
}

run_unit_tests() {
    echo -e "${YELLOW}Running Unit Tests...${NC}"
    cd "$PROJECT_DIR"
    mvn test -DskipIntegrationTests
    echo -e "${GREEN}Unit tests completed!${NC}"
}

run_integration_tests() {
    echo -e "${YELLOW}Running Integration Tests...${NC}"
    echo "Note: Make sure all services are running!"
    echo ""

    cd "$PROJECT_DIR/integration-tests"
    mvn verify
    echo -e "${GREEN}Integration tests completed!${NC}"
}

run_health_checks() {
    echo -e "${YELLOW}Running Health Checks...${NC}"
    "$SCRIPT_DIR/health-check.sh"
}

run_load_tests() {
    echo -e "${YELLOW}Running Load Tests...${NC}"

    if ! command -v k6 &> /dev/null; then
        echo -e "${RED}K6 is not installed. Please install it first:${NC}"
        echo "  - Mac: brew install k6"
        echo "  - Windows: choco install k6"
        echo "  - Linux: https://k6.io/docs/getting-started/installation/"
        exit 1
    fi

    k6 run "$PROJECT_DIR/tests/k6/load-test.js"
    echo -e "${GREEN}Load tests completed!${NC}"
}

run_stress_tests() {
    echo -e "${YELLOW}Running Stress Tests...${NC}"

    if ! command -v k6 &> /dev/null; then
        echo -e "${RED}K6 is not installed. Please install it first.${NC}"
        exit 1
    fi

    k6 run "$PROJECT_DIR/tests/k6/stress-test.js"
    echo -e "${GREEN}Stress tests completed!${NC}"
}

# Main
case "$1" in
    unit)
        run_unit_tests
        ;;
    integration)
        run_integration_tests
        ;;
    health)
        run_health_checks
        ;;
    load)
        run_load_tests
        ;;
    stress)
        run_stress_tests
        ;;
    all)
        run_health_checks
        run_unit_tests
        run_integration_tests
        run_load_tests
        ;;
    help|--help|-h)
        print_usage
        ;;
    *)
        print_usage
        exit 1
        ;;
esac
