FROM eclipse-temurin:17-jre-alpine

LABEL maintainer="Online Cart Team"
LABEL description="Discovery Server (Eureka) for Online Cart Microservices"

WORKDIR /app

COPY target/*.jar app.jar

EXPOSE 8761

ENV JAVA_OPTS="-Xms256m -Xmx512m"

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget -q --spider http://localhost:8761/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
