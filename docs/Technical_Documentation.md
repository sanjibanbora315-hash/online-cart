# Online Cart - Technical Documentation

## 1. Architecture Overview

### 1.1 System Architecture

```
                                ┌──────────────────┐
                                │   Config Server  │
                                │    (Port 8888)   │
                                └────────┬─────────┘
                                         │ Configuration
                                         ▼
┌─────────────┐    ┌────────────┐    ┌──────────────────┐
│   Clients   │───▶│ API Gateway│───▶│ Discovery Server │
│ (Web/Mobile)│    │ (Port 8080)│    │  (Eureka 8761)   │
└─────────────┘    └──────┬─────┘    └────────┬─────────┘
                          │                    │ Service Registry
                          ▼                    ▼
        ┌─────────────────┴────────────────────┴─────────────────┐
        │                         │                              │
        ▼                         ▼                              ▼
┌───────────────┐       ┌───────────────┐              ┌───────────────┐
│  User Service │       │Product Service│              │ Order Service │
│  (Port 8081)  │       │  (Port 8082)  │              │  (Port 8083)  │
└───────┬───────┘       └───────┬───────┘              └───────┬───────┘
        │                       │                              │
        │         ┌─────────────┴──────────────┐               │
        │         │                            │               │
        ▼         ▼                            ▼               ▼
┌─────────────────────┐              ┌─────────────────────────────────┐
│       MySQL         │              │            Redis                │
│  user_db │product_db│              │          (Cache)                │
│  order_db           │              └─────────────────────────────────┘
└─────────────────────┘
        │                                      │
        └──────────────────┬───────────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │    Apache Kafka        │
              │  (Event Streaming)     │
              └────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    ELK Stack (Logging)                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐               │
│  │ Elasticsearch│◀─│   Logstash   │◀─│   Services   │               │
│  └──────┬───────┘  └──────────────┘  └──────────────┘               │
│         │                                                            │
│         ▼                                                            │
│  ┌──────────────┐                                                   │
│  │    Kibana    │                                                   │
│  └──────────────┘                                                   │
└──────────────────────────────────────────────────────────────────────┘
```

### 1.2 Architecture Patterns

| Pattern | Implementation |
|---------|----------------|
| Microservices | Independent deployable services |
| API Gateway | Spring Cloud Gateway |
| Service Discovery | Netflix Eureka |
| Configuration Management | Spring Cloud Config |
| Database per Service | Separate MySQL databases |
| Event-Driven | Apache Kafka |
| Caching | Redis |
| Centralized Logging | ELK Stack |

---

## 2. Technology Stack

### 2.1 Core Technologies

| Category | Technology | Version |
|----------|------------|---------|
| Language | Java | 17 |
| Framework | Spring Boot | 3.2.5 |
| Cloud Framework | Spring Cloud | 2023.0.1 |
| Build Tool | Maven | 3.x |

### 2.2 Data Layer

| Technology | Purpose | Version |
|------------|---------|---------|
| MySQL | Primary database | 8.0 |
| Redis | Caching & sessions | 7.x |
| Spring Data JPA | ORM | 3.2.x |
| HikariCP | Connection pooling | 5.x |

### 2.3 Messaging & Events

| Technology | Purpose | Version |
|------------|---------|---------|
| Apache Kafka | Event streaming | 7.5.0 |
| Zookeeper | Kafka coordination | 7.5.0 |
| Spring Kafka | Kafka integration | 3.1.x |

### 2.4 Infrastructure

| Technology | Purpose | Version |
|------------|---------|---------|
| Docker | Containerization | 24.x |
| Docker Compose | Local orchestration | 2.x |
| Kubernetes | Production orchestration | 1.28+ |

### 2.5 Observability

| Technology | Purpose | Version |
|------------|---------|---------|
| Elasticsearch | Log storage | 8.11.0 |
| Logstash | Log processing | 8.11.0 |
| Kibana | Log visualization | 8.11.0 |
| Micrometer | Metrics | 1.12.x |
| Spring Actuator | Health/Metrics endpoints | 3.2.x |

### 2.6 Testing

| Technology | Purpose | Version |
|------------|---------|---------|
| JUnit 5 | Unit testing | 5.10.x |
| REST Assured | API testing | 5.4.0 |
| TestContainers | Integration testing | 1.19.7 |
| K6 | Load testing | 0.47.x |
| Postman/Newman | API collections | Latest |

### 2.7 Dependencies (Parent POM)

```xml
<!-- Core -->
spring-boot-starter-web
spring-boot-starter-data-jpa
spring-boot-starter-validation
spring-boot-starter-actuator

<!-- Database -->
mysql-connector-j
spring-boot-starter-data-redis

<!-- Messaging -->
spring-kafka
spring-boot-starter-mail

<!-- Spring Cloud -->
spring-cloud-starter-netflix-eureka-client
spring-cloud-starter-netflix-eureka-server
spring-cloud-starter-config
spring-cloud-config-server
spring-cloud-starter-gateway
spring-cloud-starter-openfeign

<!-- Observability -->
logstash-logback-encoder (7.4)
micrometer-registry-prometheus

<!-- Utilities -->
lombok
```

---

## 3. Module Structure

### 3.1 Project Layout

```
online-cart/
├── pom.xml                              # Parent POM
│
├── config-server/                       # Configuration Server
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/main/
│       ├── java/.../ConfigServerApplication.java
│       └── resources/application.yml
│
├── discovery-server/                    # Eureka Server
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/main/
│       ├── java/.../DiscoveryServerApplication.java
│       └── resources/application.yml
│
├── api-gateway/                         # API Gateway
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/main/
│       ├── java/.../ApiGatewayApplication.java
│       └── resources/application.yml
│
├── user-service/                        # User Management
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/main/
│       ├── java/.../UserServiceApplication.java
│       └── resources/
│           ├── application.yml
│           └── logback-spring.xml
│
├── product-service/                     # Product Catalog
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/main/
│       ├── java/.../ProductServiceApplication.java
│       └── resources/
│           ├── application.yml
│           └── logback-spring.xml
│
├── order-service/                       # Order Processing
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/main/
│       ├── java/.../OrderServiceApplication.java
│       └── resources/
│           ├── application.yml
│           └── logback-spring.xml
│
├── integration-tests/                   # Integration Tests
│   ├── pom.xml
│   └── src/test/java/com/onlinecart/
│       ├── BaseIntegrationTest.java
│       ├── HealthCheckIT.java
│       ├── UserServiceIT.java
│       ├── ProductServiceIT.java
│       ├── OrderServiceIT.java
│       └── EndToEndIT.java
│
├── docker/                              # Docker configs
│   ├── mysql/init/01-init-databases.sql
│   └── logstash/
│       ├── config/logstash.yml
│       └── pipeline/logstash.conf
│
├── k8s/                                 # Kubernetes manifests
│   ├── namespace.yml
│   ├── base/
│   │   ├── configmap.yml
│   │   ├── secrets.yml
│   │   ├── mysql.yml
│   │   ├── redis.yml
│   │   └── kafka.yml
│   └── services/
│       ├── config-server.yml
│       ├── discovery-server.yml
│       ├── api-gateway.yml
│       ├── user-service.yml
│       ├── product-service.yml
│       └── order-service.yml
│
├── tests/                               # Test resources
│   ├── postman/Online-Cart-API.postman_collection.json
│   └── k6/
│       ├── load-test.js
│       └── stress-test.js
│
├── scripts/                             # Helper scripts
│   ├── build.sh
│   ├── start-infra.sh
│   ├── start-services.sh
│   ├── stop-all.sh
│   ├── deploy-k8s.sh
│   ├── health-check.sh
│   └── run-tests.sh
│
├── docs/                                # Documentation
│   ├── Project_Document.md
│   ├── Technical_Documentation.md
│   ├── Infrastructure_Guide.md
│   └── Testing_Guide.md
│
└── docker-compose.yml                   # Docker Compose
```

### 3.2 Module Descriptions

| Module | Annotations | Dependencies |
|--------|-------------|--------------|
| config-server | `@EnableConfigServer` | spring-cloud-config-server |
| discovery-server | `@EnableEurekaServer` | spring-cloud-starter-netflix-eureka-server |
| api-gateway | `@SpringBootApplication` | spring-cloud-starter-gateway |
| user-service | `@EnableFeignClients` | eureka-client, JPA, Redis, Kafka, Mail |
| product-service | `@EnableFeignClients` | eureka-client, JPA, Redis, Kafka |
| order-service | `@EnableFeignClients` | eureka-client, JPA, Redis, Kafka, Mail |

---

## 4. Database Design

### 4.1 Database Strategy

- **Pattern**: Database per Service
- **Database**: MySQL 8.0
- **ORM**: Spring Data JPA with Hibernate
- **Connection Pool**: HikariCP

### 4.2 Databases

| Service | Database | Tables |
|---------|----------|--------|
| User Service | user_db | users, addresses |
| Product Service | product_db | products, categories, product_reviews |
| Order Service | order_db | orders, order_items, cart_items |

### 4.3 Schema Details

#### User Database (user_db)

```sql
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone VARCHAR(20),
    role VARCHAR(20) DEFAULT 'USER',
    enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE addresses (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    street VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

#### Product Database (product_db)

```sql
CREATE TABLE categories (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
);

CREATE TABLE products (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    quantity INT DEFAULT 0,
    sku VARCHAR(50) UNIQUE,
    category_id BIGINT,
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

CREATE TABLE product_reviews (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);
```

#### Order Database (order_db)

```sql
CREATE TABLE orders (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(30) DEFAULT 'PENDING',
    shipping_address TEXT,
    payment_method VARCHAR(50),
    payment_status VARCHAR(30) DEFAULT 'PENDING',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

CREATE TABLE cart_items (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_cart_item (user_id, product_id)
);
```

---

## 5. API Specifications

### 5.1 API Gateway Routes

| Route Pattern | Target Service | Description |
|---------------|----------------|-------------|
| /api/users/** | user-service | User operations |
| /api/products/** | product-service | Product operations |
| /api/orders/** | order-service | Order operations |
| /eureka/** | discovery-server | Eureka dashboard |

### 5.2 User Service API

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/users/register | Register new user |
| POST | /api/users/login | User login |
| GET | /api/users/{id} | Get user by ID |
| PUT | /api/users/{id} | Update user |
| DELETE | /api/users/{id} | Delete user |

### 5.3 Product Service API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/products | List all products |
| GET | /api/products/{id} | Get product by ID |
| POST | /api/products | Create product |
| PUT | /api/products/{id} | Update product |
| DELETE | /api/products/{id} | Delete product |
| GET | /api/products/search | Search products |
| PATCH | /api/products/{id}/inventory | Update inventory |

### 5.4 Order Service API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/orders | List user orders |
| GET | /api/orders/{id} | Get order by ID |
| POST | /api/orders | Create order |
| PATCH | /api/orders/{id}/status | Update order status |
| DELETE | /api/orders/{id} | Cancel order |
| POST | /api/orders/cart/items | Add to cart |
| GET | /api/orders/cart | Get cart |
| DELETE | /api/orders/cart/items/{id} | Remove from cart |

---

## 6. Kafka Event Topics

### 6.1 Topics

| Topic | Publisher | Consumers | Purpose |
|-------|-----------|-----------|---------|
| order-created-topic | Order Service | User, Product | New order notifications |
| order-updated-topic | Order Service | User | Order status updates |
| inventory-update-topic | Product Service | Order | Stock changes |
| notification-topic | All Services | Notification | Email/SMS triggers |

### 6.2 Event Schema Example

```json
{
  "eventId": "uuid",
  "eventType": "ORDER_CREATED",
  "timestamp": "2024-01-01T12:00:00Z",
  "payload": {
    "orderId": 123,
    "userId": 456,
    "totalAmount": 299.99,
    "items": [...]
  }
}
```

---

## 7. Caching Strategy

### 7.1 Redis Usage

| Service | Cache Key Pattern | TTL | Purpose |
|---------|-------------------|-----|---------|
| Product | `product:{id}` | 1 hour | Product details |
| Product | `products:all` | 5 min | Product list |
| User | `user:{id}` | 30 min | User profile |
| Order | `cart:{userId}` | 24 hours | Shopping cart |

### 7.2 Configuration

```yaml
spring:
  data:
    redis:
      host: ${REDIS_HOST:localhost}
      port: 6379
      timeout: 2000ms
      lettuce:
        pool:
          max-active: 8
          max-idle: 8
          min-idle: 2
```

---

## 8. Logging Architecture

### 8.1 Log Flow

```
Application → Logback → Logstash (TCP:5000) → Elasticsearch → Kibana
```

### 8.2 Log Format (JSON)

```json
{
  "@timestamp": "2024-01-01T12:00:00.000Z",
  "application": "user-service",
  "level": "INFO",
  "logger_name": "com.onlinecart.UserController",
  "message": "User registered successfully",
  "thread_name": "http-nio-8081-exec-1",
  "traceId": "abc123"
}
```

### 8.3 Kibana Index Pattern

- Index: `online-cart-logs-*`
- Time field: `@timestamp`

---

## 9. Build and Deployment

### 9.1 Build Commands

```bash
# Build all modules
mvn clean package -DskipTests

# Build with tests
mvn clean package

# Build Docker images
./scripts/build.sh --skip-tests --docker

# Build specific module
mvn clean package -pl user-service -am
```

### 9.2 Startup Order

1. **Config Server** (Port 8888)
2. **Discovery Server** (Port 8761)
3. **Infrastructure** (MySQL, Redis, Kafka)
4. **API Gateway** (Port 8080)
5. **Business Services** (User, Product, Order)

### 9.3 Docker Compose

```bash
# Start everything
docker-compose up -d

# Start infrastructure only
docker-compose up -d mysql redis zookeeper kafka

# View logs
docker-compose logs -f service-name

# Stop all
docker-compose down
```

### 9.4 Kubernetes

```bash
# Deploy all
./scripts/deploy-k8s.sh

# Check status
kubectl get pods -n online-cart
kubectl get svc -n online-cart

# Scale service
kubectl scale deployment user-service --replicas=3 -n online-cart
```

---

## 10. Health & Monitoring

### 10.1 Actuator Endpoints

| Endpoint | Description |
|----------|-------------|
| /actuator/health | Health status |
| /actuator/info | Application info |
| /actuator/metrics | Metrics data |
| /actuator/prometheus | Prometheus format |

### 10.2 Health Check Script

```bash
./scripts/health-check.sh
```

---

## 11. Testing

### 11.1 Test Types

| Type | Location | Command |
|------|----------|---------|
| Unit | `*/src/test/java` | `mvn test` |
| Integration | `integration-tests/` | `mvn verify -pl integration-tests` |
| Load | `tests/k6/` | `k6 run tests/k6/load-test.js` |
| API | `tests/postman/` | `newman run tests/postman/*.json` |

### 11.2 Run All Tests

```bash
./scripts/run-tests.sh all
```

---

## 12. Security Considerations

### 12.1 Implemented

- Input validation (Bean Validation)
- Password hashing (BCrypt-ready)
- Environment-based configuration
- Secrets management (K8s Secrets)

### 12.2 Recommended for Production

- JWT authentication
- HTTPS/TLS
- API rate limiting
- Network policies (K8s)
- Secret management (Vault)
- Database encryption

---

## 13. Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| SPRING_PROFILES_ACTIVE | Active profile | default |
| SPRING_DATASOURCE_URL | Database URL | jdbc:mysql://localhost:3306/db |
| SPRING_DATA_REDIS_HOST | Redis host | localhost |
| SPRING_KAFKA_BOOTSTRAP_SERVERS | Kafka servers | localhost:29092 |
| EUREKA_CLIENT_SERVICEURL_DEFAULTZONE | Eureka URL | http://localhost:8761/eureka/ |
| LOGSTASH_HOST | Logstash host | localhost |

---

## 14. Troubleshooting

| Issue | Solution |
|-------|----------|
| Service not registering | Check Eureka URL and network |
| Database connection error | Verify credentials and host |
| Kafka connection failed | Ensure Zookeeper is running |
| Logs not in Kibana | Check Logstash pipeline |
| Config not loading | Verify Config Server URL |

---

## 15. References

- [Spring Boot Documentation](https://docs.spring.io/spring-boot/docs/current/reference/html/)
- [Spring Cloud Documentation](https://spring.io/projects/spring-cloud)
- [Netflix Eureka](https://github.com/Netflix/eureka)
- [Apache Kafka](https://kafka.apache.org/documentation/)
- [Elasticsearch Guide](https://www.elastic.co/guide/index.html)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

---

## 16. Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2024 | Initial documentation |
| 1.1 | 2024 | Added infrastructure (Docker, K8s, ELK) |
| 1.2 | 2024 | Added testing documentation |
