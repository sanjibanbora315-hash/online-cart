package com.onlinecart;

import org.junit.jupiter.api.*;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

/**
 * Integration tests for Order Service.
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@DisplayName("Order Service Integration Tests")
public class OrderServiceIT extends BaseIntegrationTest {

    private static final String ORDERS_ENDPOINT = "/api/orders";
    private static final String CART_ENDPOINT = "/api/orders/cart";
    private static Long createdOrderId;
    private static final Long TEST_USER_ID = 1L;
    private static final Long TEST_PRODUCT_ID = 1L;

    @Test
    @Order(1)
    @DisplayName("Should add item to cart")
    void shouldAddItemToCart() {
        String cartItemJson = String.format("""
            {
                "userId": %d,
                "productId": %d,
                "quantity": 2
            }
            """, TEST_USER_ID, TEST_PRODUCT_ID);

        givenRequest()
            .body(cartItemJson)
        .when()
            .post(CART_ENDPOINT + "/items")
        .then()
            .statusCode(anyOf(is(200), is(201)));
    }

    @Test
    @Order(2)
    @DisplayName("Should get cart items")
    void shouldGetCartItems() {
        givenRequest()
            .queryParam("userId", TEST_USER_ID)
        .when()
            .get(CART_ENDPOINT)
        .then()
            .statusCode(200)
            .body("$", hasSize(greaterThanOrEqualTo(0)));
    }

    @Test
    @Order(3)
    @DisplayName("Should create order from cart")
    void shouldCreateOrderFromCart() {
        String orderJson = String.format("""
            {
                "userId": %d,
                "shippingAddress": "123 Test Street, Test City, TC 12345",
                "paymentMethod": "CREDIT_CARD"
            }
            """, TEST_USER_ID);

        createdOrderId = givenRequest()
            .body(orderJson)
        .when()
            .post(ORDERS_ENDPOINT)
        .then()
            .statusCode(anyOf(is(200), is(201)))
            .body("userId", equalTo(TEST_USER_ID.intValue()))
            .body("status", anyOf(equalTo("PENDING"), equalTo("CREATED")))
            .body("id", notNullValue())
            .extract()
            .jsonPath()
            .getLong("id");
    }

    @Test
    @Order(4)
    @DisplayName("Should get order by ID")
    void shouldGetOrderById() {
        Assumptions.assumeTrue(createdOrderId != null, "Order must be created first");

        givenRequest()
        .when()
            .get(ORDERS_ENDPOINT + "/" + createdOrderId)
        .then()
            .statusCode(200)
            .body("id", equalTo(createdOrderId.intValue()));
    }

    @Test
    @Order(5)
    @DisplayName("Should get user orders")
    void shouldGetUserOrders() {
        givenRequest()
            .queryParam("userId", TEST_USER_ID)
        .when()
            .get(ORDERS_ENDPOINT)
        .then()
            .statusCode(200)
            .body("$", hasSize(greaterThanOrEqualTo(0)));
    }

    @Test
    @Order(6)
    @DisplayName("Should update order status")
    void shouldUpdateOrderStatus() {
        Assumptions.assumeTrue(createdOrderId != null, "Order must be created first");

        String statusUpdate = """
            {
                "status": "PROCESSING"
            }
            """;

        givenRequest()
            .body(statusUpdate)
        .when()
            .patch(ORDERS_ENDPOINT + "/" + createdOrderId + "/status")
        .then()
            .statusCode(anyOf(is(200), is(204)));
    }

    @Test
    @Order(7)
    @DisplayName("Should cancel order")
    void shouldCancelOrder() {
        Assumptions.assumeTrue(createdOrderId != null, "Order must be created first");

        givenRequest()
        .when()
            .delete(ORDERS_ENDPOINT + "/" + createdOrderId)
        .then()
            .statusCode(anyOf(is(200), is(204)));
    }
}
