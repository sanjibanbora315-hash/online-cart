package com.onlinecart;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import io.restassured.specification.RequestSpecification;
import org.junit.jupiter.api.BeforeAll;

/**
 * Base class for integration tests.
 * Configures REST Assured and provides common utilities.
 */
public abstract class BaseIntegrationTest {

    protected static final String API_GATEWAY_URL = System.getProperty("api.gateway.url", "http://localhost:8080");
    protected static final String CONFIG_SERVER_URL = System.getProperty("config.server.url", "http://localhost:8888");
    protected static final String DISCOVERY_SERVER_URL = System.getProperty("discovery.server.url", "http://localhost:8761");

    @BeforeAll
    static void setup() {
        RestAssured.baseURI = API_GATEWAY_URL;
        RestAssured.enableLoggingOfRequestAndResponseIfValidationFails();
    }

    protected RequestSpecification givenRequest() {
        return RestAssured.given()
                .contentType(ContentType.JSON)
                .accept(ContentType.JSON);
    }

    protected RequestSpecification givenAuthenticatedRequest(String token) {
        return givenRequest()
                .header("Authorization", "Bearer " + token);
    }
}
