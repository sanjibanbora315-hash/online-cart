package com.onlinecart;

import org.junit.jupiter.api.*;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

/**
 * Integration tests for Product Service.
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@DisplayName("Product Service Integration Tests")
public class ProductServiceIT extends BaseIntegrationTest {

    private static final String PRODUCTS_ENDPOINT = "/api/products";
    private static Long createdProductId;

    @Test
    @Order(1)
    @DisplayName("Should create a new product")
    void shouldCreateProduct() {
        String productJson = """
            {
                "name": "Test Product",
                "description": "A test product for integration testing",
                "price": 99.99,
                "quantity": 100,
                "sku": "TEST-001"
            }
            """;

        createdProductId = givenRequest()
            .body(productJson)
        .when()
            .post(PRODUCTS_ENDPOINT)
        .then()
            .statusCode(anyOf(is(200), is(201)))
            .body("name", equalTo("Test Product"))
            .body("price", equalTo(99.99f))
            .body("id", notNullValue())
            .extract()
            .jsonPath()
            .getLong("id");
    }

    @Test
    @Order(2)
    @DisplayName("Should get all products")
    void shouldGetAllProducts() {
        givenRequest()
        .when()
            .get(PRODUCTS_ENDPOINT)
        .then()
            .statusCode(200)
            .body("$", hasSize(greaterThanOrEqualTo(1)));
    }

    @Test
    @Order(3)
    @DisplayName("Should get product by ID")
    void shouldGetProductById() {
        Assumptions.assumeTrue(createdProductId != null, "Product must be created first");

        givenRequest()
        .when()
            .get(PRODUCTS_ENDPOINT + "/" + createdProductId)
        .then()
            .statusCode(200)
            .body("id", equalTo(createdProductId.intValue()))
            .body("name", equalTo("Test Product"));
    }

    @Test
    @Order(4)
    @DisplayName("Should update product price")
    void shouldUpdateProductPrice() {
        Assumptions.assumeTrue(createdProductId != null, "Product must be created first");

        String updateJson = """
            {
                "price": 149.99
            }
            """;

        givenRequest()
            .body(updateJson)
        .when()
            .put(PRODUCTS_ENDPOINT + "/" + createdProductId)
        .then()
            .statusCode(200)
            .body("price", equalTo(149.99f));
    }

    @Test
    @Order(5)
    @DisplayName("Should update product quantity")
    void shouldUpdateProductQuantity() {
        Assumptions.assumeTrue(createdProductId != null, "Product must be created first");

        String updateJson = """
            {
                "quantity": 50
            }
            """;

        givenRequest()
            .body(updateJson)
        .when()
            .patch(PRODUCTS_ENDPOINT + "/" + createdProductId + "/inventory")
        .then()
            .statusCode(anyOf(is(200), is(204)));
    }

    @Test
    @Order(6)
    @DisplayName("Should search products by name")
    void shouldSearchProductsByName() {
        givenRequest()
            .queryParam("name", "Test")
        .when()
            .get(PRODUCTS_ENDPOINT + "/search")
        .then()
            .statusCode(200)
            .body("$", hasSize(greaterThanOrEqualTo(0)));
    }

    @Test
    @Order(7)
    @DisplayName("Should delete product")
    void shouldDeleteProduct() {
        Assumptions.assumeTrue(createdProductId != null, "Product must be created first");

        givenRequest()
        .when()
            .delete(PRODUCTS_ENDPOINT + "/" + createdProductId)
        .then()
            .statusCode(anyOf(is(200), is(204)));
    }
}
