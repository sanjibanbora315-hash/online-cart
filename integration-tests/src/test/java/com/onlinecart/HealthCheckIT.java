package com.onlinecart;

import io.restassured.RestAssured;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.parallel.Execution;
import org.junit.jupiter.api.parallel.ExecutionMode;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

/**
 * Integration tests to verify all services are healthy and responding.
 */
@Execution(ExecutionMode.CONCURRENT)
public class HealthCheckIT extends BaseIntegrationTest {

    @Test
    @DisplayName("Config Server should be healthy")
    void configServerHealthCheck() {
        given()
            .baseUri(CONFIG_SERVER_URL)
        .when()
            .get("/actuator/health")
        .then()
            .statusCode(200)
            .body("status", equalTo("UP"));
    }

    @Test
    @DisplayName("Discovery Server should be healthy")
    void discoveryServerHealthCheck() {
        given()
            .baseUri(DISCOVERY_SERVER_URL)
        .when()
            .get("/actuator/health")
        .then()
            .statusCode(200)
            .body("status", equalTo("UP"));
    }

    @Test
    @DisplayName("API Gateway should be healthy")
    void apiGatewayHealthCheck() {
        given()
            .baseUri(API_GATEWAY_URL)
        .when()
            .get("/actuator/health")
        .then()
            .statusCode(200)
            .body("status", equalTo("UP"));
    }

    @Test
    @DisplayName("User Service should be healthy via Gateway")
    void userServiceHealthCheck() {
        given()
            .baseUri("http://localhost:8081")
        .when()
            .get("/actuator/health")
        .then()
            .statusCode(200)
            .body("status", equalTo("UP"));
    }

    @Test
    @DisplayName("Product Service should be healthy via Gateway")
    void productServiceHealthCheck() {
        given()
            .baseUri("http://localhost:8082")
        .when()
            .get("/actuator/health")
        .then()
            .statusCode(200)
            .body("status", equalTo("UP"));
    }

    @Test
    @DisplayName("Order Service should be healthy via Gateway")
    void orderServiceHealthCheck() {
        given()
            .baseUri("http://localhost:8083")
        .when()
            .get("/actuator/health")
        .then()
            .statusCode(200)
            .body("status", equalTo("UP"));
    }

    @Test
    @DisplayName("Eureka should have registered services")
    void eurekaRegisteredServices() {
        given()
            .baseUri(DISCOVERY_SERVER_URL)
            .accept("application/json")
        .when()
            .get("/eureka/apps")
        .then()
            .statusCode(200)
            .body("applications.application", hasSize(greaterThanOrEqualTo(1)));
    }
}
