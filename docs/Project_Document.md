# Online Cart - Project Document

## 1. Project Overview

**Project Name:** Online Cart
**Version:** 1.0-SNAPSHOT
**Type:** E-Commerce Microservices Platform

Online Cart is a modern, scalable e-commerce platform built using microservices architecture. The system is designed to handle online shopping operations including user management, product catalog, and order processing with enterprise-grade infrastructure.

---

## 2. Project Scope

### 2.1 In Scope

- **User Management**: Registration, authentication, and user profile management
- **Product Catalog**: Product listing, search, and inventory management
- **Order Processing**: Shopping cart, order placement, and order history
- **Service Discovery**: Automatic service registration and discovery (Eureka)
- **Centralized Configuration**: Externalized configuration management
- **API Gateway**: Single entry point for all client requests
- **Caching**: Redis-based caching for improved performance
- **Messaging**: Kafka-based event-driven communication
- **Email Notifications**: Email service integration (Mailpit for testing)
- **Centralized Logging**: ELK Stack (Elasticsearch, Logstash, Kibana)
- **Containerization**: Docker and Kubernetes support
- **Testing**: Unit, Integration, Load, and Stress testing

### 2.2 Out of Scope (Future Enhancements)

- Payment gateway integration (Stripe, PayPal)
- Real-time notifications (WebSocket)
- Recommendation engine
- Analytics and reporting dashboard
- Mobile application
- Multi-tenancy support

---

## 3. Business Objectives

1. **Scalability**: Handle increasing user load by scaling individual services
2. **Maintainability**: Independent deployment and updates of services
3. **Resilience**: Failure isolation - one service failure doesn't bring down the entire system
4. **Flexibility**: Technology independence for each microservice
5. **Observability**: Comprehensive logging, monitoring, and tracing
6. **Time to Market**: Faster development cycles with smaller, focused teams

---

## 4. System Architecture

### 4.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              CLIENTS                                     │
│                    (Web Browser / Mobile App)                           │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                          API GATEWAY (:8080)                            │
│                    (Routing, Load Balancing)                            │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  │
        ┌─────────────────────────┼─────────────────────────┐
        │                         │                         │
        ▼                         ▼                         ▼
┌───────────────┐       ┌───────────────┐       ┌───────────────┐
│ USER SERVICE  │       │PRODUCT SERVICE│       │ ORDER SERVICE │
│   (:8081)     │       │   (:8082)     │       │   (:8083)     │
└───────┬───────┘       └───────┬───────┘       └───────┬───────┘
        │                       │                       │
        ▼                       ▼                       ▼
┌───────────────┐       ┌───────────────┐       ┌───────────────┐
│   user_db     │       │  product_db   │       │   order_db    │
│   (MySQL)     │       │   (MySQL)     │       │   (MySQL)     │
└───────────────┘       └───────────────┘       └───────────────┘

                    SUPPORTING SERVICES
┌─────────────┬─────────────┬─────────────┬─────────────┐
│   CONFIG    │  DISCOVERY  │    REDIS    │    KAFKA    │
│   SERVER    │   SERVER    │   (Cache)   │  (Events)   │
│  (:8888)    │  (:8761)    │  (:6379)    │  (:9092)    │
└─────────────┴─────────────┴─────────────┴─────────────┘

                    OBSERVABILITY STACK
┌─────────────┬─────────────┬─────────────┬─────────────┐
│ELASTICSEARCH│  LOGSTASH   │   KIBANA    │   MAILPIT   │
│  (:9200)    │  (:5000)    │  (:5601)    │  (:8025)    │
└─────────────┴─────────────┴─────────────┴─────────────┘
```

### 4.2 Service Components

| Service | Port | Description |
|---------|------|-------------|
| Config Server | 8888 | Centralized configuration management |
| Discovery Server | 8761 | Service registry (Netflix Eureka) |
| API Gateway | 8080 | Request routing and load balancing |
| User Service | 8081 | User registration and authentication |
| Product Service | 8082 | Product catalog management |
| Order Service | 8083 | Order processing and management |

### 4.3 Infrastructure Components

| Component | Port(s) | Description |
|-----------|---------|-------------|
| MySQL | 3306 | Primary database (3 databases) |
| Redis | 6379 | Caching and session storage |
| Kafka | 9092, 29092 | Event streaming and messaging |
| Zookeeper | 2181 | Kafka coordination |
| Kafka UI | 8090 | Kafka management interface |
| Elasticsearch | 9200 | Log storage and search |
| Logstash | 5000 | Log processing pipeline |
| Kibana | 5601 | Log visualization dashboard |
| Mailpit | 1025, 8025 | Email testing (SMTP + Web UI) |

---

## 5. Key Features

### 5.1 User Service
- User registration with validation
- User authentication (JWT-ready)
- Profile management
- Role-based access control
- Address management

### 5.2 Product Service
- Product CRUD operations
- Category management
- Inventory tracking
- Product search and filtering
- Product reviews

### 5.3 Order Service
- Shopping cart management
- Order placement
- Order status tracking
- Order history
- Kafka event publishing

### 5.4 Infrastructure Features
- **Config Server**: Externalized configuration for all services
- **Discovery Server**: Dynamic service discovery using Netflix Eureka
- **API Gateway**: Routing, filtering, and cross-cutting concerns
- **Redis Cache**: Distributed caching for improved performance
- **Kafka Messaging**: Asynchronous event-driven communication
- **ELK Stack**: Centralized logging and visualization
- **Mailpit**: Email testing in development

---

## 6. Technology Stack

| Category | Technology | Version |
|----------|------------|---------|
| Language | Java | 17 |
| Framework | Spring Boot | 3.2.5 |
| Cloud | Spring Cloud | 2023.0.1 |
| Build Tool | Maven | 3.x |
| Database | MySQL | 8.0 |
| Cache | Redis | 7.x |
| Messaging | Apache Kafka | 7.5.0 (Confluent) |
| Search/Logging | Elasticsearch | 8.11.0 |
| Log Processing | Logstash | 8.11.0 |
| Visualization | Kibana | 8.11.0 |
| Containerization | Docker | 24.x |
| Orchestration | Kubernetes | 1.28+ |
| Testing | JUnit 5, REST Assured, K6 | Latest |

---

## 7. Project Structure

```
online-cart/
├── api-gateway/                 # API Gateway Service
├── config-server/               # Configuration Server
├── discovery-server/            # Eureka Discovery Server
├── user-service/                # User Management Service
├── product-service/             # Product Catalog Service
├── order-service/               # Order Processing Service
├── integration-tests/           # Integration Test Suite
├── docker/                      # Docker configurations
│   ├── mysql/init/              # Database init scripts
│   └── logstash/                # Logstash pipeline config
├── k8s/                         # Kubernetes manifests
│   ├── base/                    # Infrastructure (MySQL, Redis, Kafka)
│   └── services/                # Microservice deployments
├── tests/                       # Test resources
│   ├── postman/                 # Postman API collection
│   └── k6/                      # K6 load test scripts
├── scripts/                     # Helper scripts
│   ├── build.sh                 # Build script
│   ├── start-infra.sh           # Start infrastructure
│   ├── start-services.sh        # Start microservices
│   ├── stop-all.sh              # Stop all services
│   ├── deploy-k8s.sh            # Kubernetes deployment
│   ├── health-check.sh          # Health check script
│   └── run-tests.sh             # Test runner script
├── docs/                        # Documentation
│   ├── Project_Document.md      # This document
│   ├── Technical_Documentation.md
│   ├── Infrastructure_Guide.md
│   └── Testing_Guide.md
├── docker-compose.yml           # Docker Compose orchestration
└── pom.xml                      # Parent POM
```

---

## 8. Testing Strategy

### 8.1 Test Types

| Type | Tool | Purpose |
|------|------|---------|
| Unit Tests | JUnit 5 | Test individual components |
| Integration Tests | REST Assured | Test service APIs |
| API Tests | Postman/Newman | Manual & CI API testing |
| Load Tests | K6 | Performance testing |
| Stress Tests | K6 | Find breaking points |
| Health Checks | Shell scripts | Service availability |

### 8.2 Test Coverage

| Module | Tests |
|--------|-------|
| HealthCheckIT | All service health endpoints |
| UserServiceIT | User CRUD operations |
| ProductServiceIT | Product CRUD operations |
| OrderServiceIT | Order and cart operations |
| EndToEndIT | Complete user journey |

---

## 9. Deployment Options

### 9.1 Local Development
```bash
mvn clean package -DskipTests
java -jar service/target/service.jar
```

### 9.2 Docker Compose
```bash
docker-compose up -d
```

### 9.3 Kubernetes
```bash
./scripts/deploy-k8s.sh
```

---

## 10. Stakeholders

| Role | Responsibility |
|------|----------------|
| Product Owner | Define requirements and priorities |
| Development Team | Design, develop, and test the system |
| DevOps Engineer | CI/CD pipeline and infrastructure |
| QA Team | Quality assurance and testing |
| End Users | Customers using the e-commerce platform |

---

## 11. Project Timeline

| Phase | Description | Duration |
|-------|-------------|----------|
| Phase 1 | Project setup and infrastructure services | Week 1-2 |
| Phase 2 | Core services development (User, Product) | Week 3-5 |
| Phase 3 | Order service and integration | Week 6-7 |
| Phase 4 | Infrastructure (Docker, K8s, ELK) | Week 8-9 |
| Phase 5 | Testing and documentation | Week 10 |
| Phase 6 | Deployment and go-live | Week 11 |

---

## 12. Success Criteria

1. All microservices are independently deployable
2. Services can discover and communicate with each other
3. System handles 100+ concurrent users efficiently
4. API response time under 200ms for standard operations (P95)
5. 99.9% uptime for critical services
6. All integration tests passing
7. Load tests meet performance thresholds
8. Centralized logging operational
9. Docker and Kubernetes deployment working

---

## 13. Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Service communication failure | High | Circuit breaker pattern, retry mechanisms |
| Database bottleneck | Medium | Database per service, connection pooling, caching |
| Configuration drift | Medium | Centralized config server, version control |
| Deployment complexity | Medium | Containerization, orchestration tools, scripts |
| Message queue failure | Medium | Kafka replication, dead letter queues |
| Log data loss | Low | Async logging, buffer queues |

---

## 14. Quick Start Guide

### Prerequisites
- Java 17+
- Maven 3.x
- Docker Desktop (8GB+ RAM)
- Git

### Steps

```bash
# 1. Clone and build
git clone <repository-url>
cd online-cart
mvn clean package -DskipTests

# 2. Start infrastructure
docker-compose up -d mysql redis zookeeper kafka elasticsearch logstash kibana mailpit

# 3. Start services
docker-compose up -d

# 4. Verify health
./scripts/health-check.sh

# 5. Access services
# API Gateway: http://localhost:8080
# Eureka Dashboard: http://localhost:8761
# Kibana: http://localhost:5601
# Kafka UI: http://localhost:8090
# Mailpit: http://localhost:8025
```

---

## 15. Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2024 | Development Team | Initial document |
| 1.1 | 2024 | Development Team | Added infrastructure & testing |
