# Online Cart - Infrastructure Guide

## 1. Overview

This guide covers the infrastructure setup for the Online Cart microservices platform, including Docker, Kubernetes, databases, message queues, caching, email, and logging.

---

## 2. Infrastructure Components

| Component | Purpose | Port(s) |
|-----------|---------|---------|
| MySQL 8.0 | Primary database | 3306 |
| Redis 7 | Caching & session storage | 6379 |
| Kafka | Event streaming & messaging | 9092, 29092 |
| Zookeeper | Kafka coordination | 2181 |
| Kafka UI | Kafka management UI | 8090 |
| Mailpit | Email testing (SMTP) | 1025 (SMTP), 8025 (UI) |
| Elasticsearch | Log storage & search | 9200, 9300 |
| Logstash | Log processing | 5000, 5044 |
| Kibana | Log visualization | 5601 |

---

## 3. Docker Setup

### 3.1 Prerequisites

- Docker Desktop 4.x+
- Docker Compose 2.x+
- 8GB+ RAM allocated to Docker

### 3.2 Quick Start

```bash
# Build all services
mvn clean package -DskipTests

# Start infrastructure only
docker-compose up -d mysql redis zookeeper kafka mailpit elasticsearch logstash kibana

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

### 3.3 Docker Compose Services

```
Infrastructure:
├── mysql              - MySQL 8.0 Database
├── redis              - Redis Cache
├── zookeeper          - Kafka Coordinator
├── kafka              - Message Broker
├── kafka-ui           - Kafka Management UI
├── mailpit            - Email Testing
├── elasticsearch      - Log Storage
├── logstash           - Log Processing
└── kibana             - Log Visualization

Microservices:
├── config-server      - Configuration Server (8888)
├── discovery-server   - Eureka Server (8761)
├── api-gateway        - API Gateway (8080)
├── user-service       - User Management (8081)
├── product-service    - Product Catalog (8082)
└── order-service      - Order Processing (8083)
```

### 3.4 Building Docker Images

```bash
# Build all images
./scripts/build.sh --skip-tests --docker

# Build individual service
docker build -t online-cart/user-service:latest ./user-service
```

---

## 4. Kubernetes Deployment

### 4.1 Prerequisites

- Kubernetes cluster (minikube, kind, or cloud provider)
- kubectl configured
- Docker images pushed to registry

### 4.2 Deployment Structure

```
k8s/
├── namespace.yml           # Namespace definition
├── base/
│   ├── configmap.yml       # Environment configuration
│   ├── secrets.yml         # Sensitive data
│   ├── mysql.yml           # MySQL deployment
│   ├── redis.yml           # Redis deployment
│   └── kafka.yml           # Kafka & Zookeeper deployment
└── services/
    ├── config-server.yml   # Config Server deployment
    ├── discovery-server.yml # Eureka deployment
    ├── api-gateway.yml     # Gateway deployment
    ├── user-service.yml    # User Service deployment
    ├── product-service.yml # Product Service deployment
    └── order-service.yml   # Order Service deployment
```

### 4.3 Deploy to Kubernetes

```bash
# Deploy all resources
./scripts/deploy-k8s.sh

# Or manually:
kubectl apply -f k8s/namespace.yml
kubectl apply -f k8s/base/
kubectl apply -f k8s/services/

# Check status
kubectl get pods -n online-cart
kubectl get svc -n online-cart

# View logs
kubectl logs -f deployment/user-service -n online-cart
```

### 4.4 Scaling Services

```bash
# Scale a deployment
kubectl scale deployment user-service --replicas=3 -n online-cart

# Auto-scaling (HPA)
kubectl autoscale deployment user-service --min=2 --max=5 --cpu-percent=80 -n online-cart
```

---

## 5. MySQL Database

### 5.1 Connection Details

| Property | Development | Docker | Kubernetes |
|----------|-------------|--------|------------|
| Host | localhost | mysql | mysql |
| Port | 3306 | 3306 | 3306 |
| Username | onlinecart | onlinecart | onlinecart |
| Password | onlinecart123 | onlinecart123 | (from secret) |

### 5.2 Databases

| Database | Service |
|----------|---------|
| user_db | User Service |
| product_db | Product Service |
| order_db | Order Service |

### 5.3 Connection String

```
jdbc:mysql://localhost:3306/user_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
```

### 5.4 Accessing MySQL

```bash
# Docker
docker exec -it online-cart-mysql mysql -u onlinecart -ponlinecart123

# Kubernetes
kubectl exec -it deployment/mysql -n online-cart -- mysql -u onlinecart -ponlinecart123
```

---

## 6. Redis Cache

### 6.1 Connection Details

| Property | Value |
|----------|-------|
| Host | localhost (dev) / redis (docker/k8s) |
| Port | 6379 |
| Password | (none) |

### 6.2 Usage in Services

```yaml
spring:
  data:
    redis:
      host: ${REDIS_HOST:localhost}
      port: 6379
      timeout: 2000ms
```

### 6.3 Accessing Redis

```bash
# Docker
docker exec -it online-cart-redis redis-cli

# Commands
> PING
> KEYS *
> GET key_name
```

---

## 7. Apache Kafka

### 7.1 Connection Details

| Property | Development | Docker/K8s |
|----------|-------------|------------|
| Bootstrap Servers | localhost:29092 | kafka:9092 |
| Zookeeper | localhost:2181 | zookeeper:2181 |

### 7.2 Topics

| Topic | Publisher | Subscriber |
|-------|-----------|------------|
| order-created-topic | Order Service | User Service, Product Service |
| order-updated-topic | Order Service | User Service |
| inventory-update-topic | Product Service | Order Service |
| notification-topic | All Services | Notification Service |

### 7.3 Kafka UI

Access Kafka UI at http://localhost:8090 to:
- View topics and messages
- Monitor consumer groups
- Manage brokers

### 7.4 Kafka Commands

```bash
# List topics
docker exec online-cart-kafka kafka-topics --list --bootstrap-server localhost:9092

# Create topic
docker exec online-cart-kafka kafka-topics --create --topic my-topic --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1

# Consume messages
docker exec online-cart-kafka kafka-console-consumer --topic order-created-topic --bootstrap-server localhost:9092 --from-beginning
```

---

## 8. Mailpit (Email Testing)

### 8.1 Access

| Service | URL/Port |
|---------|----------|
| SMTP Server | localhost:1025 |
| Web UI | http://localhost:8025 |

### 8.2 Configuration

```yaml
spring:
  mail:
    host: ${MAIL_HOST:localhost}
    port: 1025
    properties:
      mail.smtp.auth: false
      mail.smtp.starttls.enable: false
```

### 8.3 Usage

All emails sent by the application in development/docker mode will be captured by Mailpit. View them at http://localhost:8025.

---

## 9. ELK Stack (Logging)

### 9.1 Components

| Component | Purpose | URL |
|-----------|---------|-----|
| Elasticsearch | Log storage | http://localhost:9200 |
| Logstash | Log processing | tcp://localhost:5000 |
| Kibana | Visualization | http://localhost:5601 |

### 9.2 Log Flow

```
Application → Logback → Logstash (TCP:5000) → Elasticsearch → Kibana
```

### 9.3 Logback Configuration

Each service uses `logback-spring.xml` to send logs to Logstash:

```xml
<appender name="LOGSTASH" class="net.logstash.logback.appender.LogstashTcpSocketAppender">
    <destination>${logstashHost}:${logstashPort}</destination>
    <encoder class="net.logstash.logback.encoder.LogstashEncoder">
        <customFields>{"application":"${appName}"}</customFields>
    </encoder>
</appender>
```

### 9.4 Kibana Setup

1. Open http://localhost:5601
2. Go to Stack Management → Index Patterns
3. Create pattern: `online-cart-logs-*`
4. Select `@timestamp` as time field
5. Go to Discover to view logs

### 9.5 Sample Queries

```
# Filter by service
application: "user-service"

# Filter by log level
level: "ERROR"

# Search message
message: "order created"

# Combined
application: "order-service" AND level: "ERROR"
```

---

## 10. Monitoring

### 10.1 Health Endpoints

Each service exposes:

| Endpoint | Description |
|----------|-------------|
| /actuator/health | Health status |
| /actuator/info | Application info |
| /actuator/metrics | Metrics data |
| /actuator/prometheus | Prometheus format |

### 10.2 Prometheus Metrics

Services expose metrics at `/actuator/prometheus` for scraping:

```yaml
scrape_configs:
  - job_name: 'online-cart'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets:
        - 'user-service:8081'
        - 'product-service:8082'
        - 'order-service:8083'
```

---

## 11. Environment Variables

### 11.1 Common Variables

| Variable | Description | Default |
|----------|-------------|---------|
| SPRING_PROFILES_ACTIVE | Active profile | default |
| EUREKA_CLIENT_SERVICEURL_DEFAULTZONE | Eureka URL | http://localhost:8761/eureka/ |
| SPRING_DATASOURCE_URL | Database URL | jdbc:mysql://localhost:3306/db |
| SPRING_DATA_REDIS_HOST | Redis host | localhost |
| SPRING_KAFKA_BOOTSTRAP_SERVERS | Kafka servers | localhost:29092 |

### 11.2 Service-Specific

| Service | Variable | Description |
|---------|----------|-------------|
| Config Server | SPRING_CLOUD_CONFIG_SERVER_NATIVE_SEARCH_LOCATIONS | Config location |
| Discovery Server | EUREKA_INSTANCE_HOSTNAME | Eureka hostname |
| API Gateway | SPRING_CLOUD_GATEWAY_ROUTES | Gateway routes |

---

## 12. Troubleshooting

### 12.1 Common Issues

| Issue | Solution |
|-------|----------|
| MySQL connection refused | Wait for MySQL container to be healthy |
| Kafka not available | Ensure Zookeeper is running first |
| Service not registering | Check Eureka URL and network |
| Logs not appearing in Kibana | Verify Logstash is running and connected |

### 12.2 Debug Commands

```bash
# Check container logs
docker-compose logs -f service-name

# Check container health
docker inspect --format='{{.State.Health.Status}}' container-name

# Network debugging
docker network inspect online-cart-network

# Kubernetes debugging
kubectl describe pod pod-name -n online-cart
kubectl logs pod-name -n online-cart --previous
```

---

## 13. Resource Requirements

### 13.1 Development (Docker)

| Component | Memory | CPU |
|-----------|--------|-----|
| MySQL | 512MB-1GB | 0.5 |
| Redis | 128MB | 0.1 |
| Kafka + Zookeeper | 1GB | 0.5 |
| ELK Stack | 2GB | 1.0 |
| Each Microservice | 256-512MB | 0.3 |
| **Total** | **~6-8GB** | **~3-4 cores** |

### 13.2 Production (Kubernetes)

| Component | Requests | Limits |
|-----------|----------|--------|
| Infrastructure | 2GB, 1 CPU | 4GB, 2 CPU |
| Each Microservice | 256MB, 0.1 CPU | 512MB, 0.3 CPU |

---

## 14. Security Considerations

### 14.1 Production Checklist

- [ ] Change default passwords in secrets
- [ ] Enable TLS for all services
- [ ] Configure network policies in Kubernetes
- [ ] Enable Redis authentication
- [ ] Configure Kafka authentication (SASL)
- [ ] Secure Elasticsearch with X-Pack
- [ ] Use secrets management (Vault, AWS Secrets Manager)

### 14.2 Network Security

```yaml
# Example Kubernetes NetworkPolicy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-gateway-policy
spec:
  podSelector:
    matchLabels:
      app: api-gateway
  ingress:
    - from: []  # Allow external traffic
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: user-service
        - podSelector:
            matchLabels:
              app: product-service
        - podSelector:
            matchLabels:
              app: order-service
```
