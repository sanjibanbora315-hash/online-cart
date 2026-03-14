# Online Cart - Testing Guide

## 1. Overview

This guide covers all testing approaches for the Online Cart microservices platform.

---

## 2. Test Types

| Type | Tool | Purpose | Location |
|------|------|---------|----------|
| Unit Tests | JUnit 5 | Test individual components | `*/src/test/java` |
| Integration Tests | REST Assured + JUnit | Test service APIs | `integration-tests/` |
| API Tests | Postman/Newman | Manual & CI API testing | `tests/postman/` |
| Load Tests | K6 | Performance testing | `tests/k6/` |
| Health Checks | Shell script | Service availability | `scripts/` |

---

## 3. Integration Tests

### 3.1 Prerequisites

- All services running (via Docker or locally)
- MySQL, Redis, Kafka available

### 3.2 Test Classes

| Class | Description |
|-------|-------------|
| `HealthCheckIT` | Verifies all services are healthy |
| `UserServiceIT` | Tests user CRUD operations |
| `ProductServiceIT` | Tests product CRUD operations |
| `OrderServiceIT` | Tests order and cart operations |
| `EndToEndIT` | Complete user journey test |

### 3.3 Running Integration Tests

```bash
# Start services first
docker-compose up -d

# Wait for services to be ready
./scripts/health-check.sh

# Run integration tests
cd integration-tests
mvn verify

# Run specific test class
mvn verify -Dtest=HealthCheckIT

# Run with custom API URL
mvn verify -Dapi.gateway.url=http://your-gateway:8080
```

### 3.4 Test Configuration

Configure test endpoints via system properties:

```bash
-Dapi.gateway.url=http://localhost:8080
-Dconfig.server.url=http://localhost:8888
-Ddiscovery.server.url=http://localhost:8761
```

---

## 4. Postman Collection

### 4.1 Import Collection

1. Open Postman
2. File → Import
3. Select `tests/postman/Online-Cart-API.postman_collection.json`

### 4.2 Collection Structure

```
Online Cart API
├── Health Checks
│   ├── API Gateway Health
│   ├── Config Server Health
│   ├── Discovery Server Health
│   ├── User Service Health
│   ├── Product Service Health
│   └── Order Service Health
├── User Service
│   ├── Register User
│   ├── Login User
│   ├── Get User by ID
│   ├── Update User
│   └── Delete User
├── Product Service
│   ├── Get All Products
│   ├── Create Product
│   ├── Get Product by ID
│   ├── Update Product
│   ├── Search Products
│   └── Delete Product
└── Order Service
    ├── Add to Cart
    ├── Get Cart
    ├── Create Order
    ├── Get Order by ID
    ├── Get User Orders
    ├── Update Order Status
    └── Cancel Order
```

### 4.3 Running with Newman (CLI)

```bash
# Install Newman
npm install -g newman

# Run collection
newman run tests/postman/Online-Cart-API.postman_collection.json

# Run with custom environment
newman run tests/postman/Online-Cart-API.postman_collection.json \
    --env-var "baseUrl=http://localhost:8080"

# Generate HTML report
newman run tests/postman/Online-Cart-API.postman_collection.json \
    --reporters cli,html \
    --reporter-html-export reports/api-test-report.html
```

---

## 5. K6 Load Testing

### 5.1 Installation

```bash
# macOS
brew install k6

# Windows
choco install k6

# Linux
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install k6
```

### 5.2 Test Scenarios

#### Load Test (`load-test.js`)
- Gradual ramp-up to 100 users
- Tests product browsing, user registration
- Validates response times and error rates

```bash
k6 run tests/k6/load-test.js
```

#### Stress Test (`stress-test.js`)
- Aggressive ramp-up to 400 users
- Identifies breaking points
- Mixed read operations

```bash
k6 run tests/k6/stress-test.js
```

### 5.3 Custom Configuration

```bash
# Override base URL
k6 run tests/k6/load-test.js -e BASE_URL=http://api.example.com

# Set custom duration
k6 run tests/k6/load-test.js --duration 5m

# Set virtual users
k6 run tests/k6/load-test.js --vus 50
```

### 5.4 K6 Output

```
          /\      |‾‾| /‾‾/   /‾‾/
     /\  /  \     |  |/  /   /  /
    /  \/    \    |     (   /   ‾‾\
   /          \   |  |\  \ |  (‾)  |
  / __________ \  |__| \__\ \_____/ .io

  execution: local
     script: tests/k6/load-test.js
     output: -

  scenarios: (100.00%) 1 scenario, 100 max VUs, 5m30s max duration
           └─ default: Up to 100 VUs for 5m0s

     ✓ health check status is 200
     ✓ products list status is 200

     http_req_duration..........: avg=45.2ms  min=12ms  max=890ms  p(95)=120ms
     http_reqs..................: 15234  50.78/s
     errors.....................: 0.12%  ✓ 18   ✗ 15216
```

---

## 6. Health Check Script

### 6.1 Usage

```bash
./scripts/health-check.sh
```

### 6.2 Sample Output

```
==========================================
  Online Cart - Health Check
==========================================

Microservices:
--------------
  ✓ Config Server: UP
  ✓ Discovery Server: UP
  ✓ API Gateway: UP
  ✓ User Service: UP
  ✓ Product Service: UP
  ✓ Order Service: UP

Infrastructure:
---------------
  ✓ MySQL: UP
  ✓ Redis: UP
  ✓ Kafka: UP
  ✓ Elasticsearch: UP
  ✓ Kibana: UP
  ✓ Mailpit: UP

Registered Services (Eureka):
-----------------------------
  ✓ API-GATEWAY
  ✓ USER-SERVICE
  ✓ PRODUCT-SERVICE
  ✓ ORDER-SERVICE
```

---

## 7. Test Runner Script

### 7.1 Usage

```bash
# Show help
./scripts/run-tests.sh help

# Run unit tests
./scripts/run-tests.sh unit

# Run integration tests
./scripts/run-tests.sh integration

# Run health checks
./scripts/run-tests.sh health

# Run load tests
./scripts/run-tests.sh load

# Run stress tests
./scripts/run-tests.sh stress

# Run all tests
./scripts/run-tests.sh all
```

---

## 8. CI/CD Integration

### 8.1 GitHub Actions Example

```yaml
name: Tests

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'
      - name: Run Unit Tests
        run: mvn test -DskipIntegrationTests

  integration-tests:
    runs-on: ubuntu-latest
    needs: unit-tests
    steps:
      - uses: actions/checkout@v3
      - name: Start Services
        run: docker-compose up -d
      - name: Wait for Services
        run: sleep 60
      - name: Run Integration Tests
        run: |
          cd integration-tests
          mvn verify

  load-tests:
    runs-on: ubuntu-latest
    needs: integration-tests
    steps:
      - uses: actions/checkout@v3
      - name: Start Services
        run: docker-compose up -d
      - name: Install K6
        run: |
          curl https://github.com/grafana/k6/releases/download/v0.47.0/k6-v0.47.0-linux-amd64.tar.gz -L | tar xvz
          sudo mv k6-v0.47.0-linux-amd64/k6 /usr/local/bin/
      - name: Run Load Tests
        run: k6 run tests/k6/load-test.js
```

---

## 9. Test Data

### 9.1 Sample Test Users

| Username | Email | Password |
|----------|-------|----------|
| testuser | testuser@example.com | SecurePass123! |
| e2euser | e2e@example.com | E2EPassword123! |

### 9.2 Sample Products

Products are pre-loaded via MySQL init script:
- Smartphone X (ID: 1)
- Laptop Pro (ID: 2)
- Wireless Earbuds (ID: 3)
- Cotton T-Shirt (ID: 4)
- Programming Guide (ID: 5)

---

## 10. Troubleshooting

### 10.1 Common Issues

| Issue | Solution |
|-------|----------|
| Connection refused | Ensure services are running |
| 404 errors | Check API Gateway routes |
| Timeout errors | Increase timeout or check service health |
| Auth errors | Verify JWT token is valid |

### 10.2 Debug Mode

```bash
# Verbose Maven output
mvn verify -X

# K6 with debug
k6 run --http-debug tests/k6/load-test.js

# Newman verbose
newman run collection.json --verbose
```

---

## 11. Best Practices

1. **Run health checks first** before integration tests
2. **Use unique test data** to avoid conflicts
3. **Clean up test data** after tests complete
4. **Monitor system resources** during load tests
5. **Run tests in isolation** for consistent results
6. **Use CI/CD** for automated testing
7. **Keep test data minimal** for faster execution
