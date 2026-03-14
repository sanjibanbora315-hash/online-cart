package com.onlinecart;

import org.junit.jupiter.api.*;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

/**
 * End-to-end integration tests simulating a complete user journey.
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@DisplayName("End-to-End Integration Tests")
public class EndToEndIT extends BaseIntegrationTest {

    private static Long userId;
    private static Long productId;
    private static Long orderId;
    private static String userToken;

    @Test
    @Order(1)
    @DisplayName("Step 1: Register a new user")
    void step1_RegisterUser() {
        String userJson = """
            {
                "username": "e2euser",
                "email": "e2e@example.com",
                "password": "E2EPassword123!",
                "firstName": "E2E",
                "lastName": "User"
            }
            """;

        userId = givenRequest()
            .body(userJson)
        .when()
            .post("/api/users/register")
        .then()
            .statusCode(anyOf(is(200), is(201)))
            .body("id", notNullValue())
            .extract()
            .jsonPath()
            .getLong("id");

        System.out.println("Created user with ID: " + userId);
    }

    @Test
    @Order(2)
    @DisplayName("Step 2: User logs in")
    void step2_UserLogin() {
        Assumptions.assumeTrue(userId != null, "User must be registered first");

        String loginJson = """
            {
                "email": "e2e@example.com",
                "password": "E2EPassword123!"
            }
            """;

        userToken = givenRequest()
            .body(loginJson)
        .when()
            .post("/api/users/login")
        .then()
            .statusCode(anyOf(is(200), is(201)))
            .body("token", notNullValue())
            .extract()
            .jsonPath()
            .getString("token");

        System.out.println("User logged in successfully");
    }

    @Test
    @Order(3)
    @DisplayName("Step 3: Browse products")
    void step3_BrowseProducts() {
        var response = givenRequest()
        .when()
            .get("/api/products")
        .then()
            .statusCode(200)
            .body("$", hasSize(greaterThanOrEqualTo(1)))
            .extract()
            .jsonPath();

        productId = response.getLong("[0].id");
        System.out.println("Found product with ID: " + productId);
    }

    @Test
    @Order(4)
    @DisplayName("Step 4: View product details")
    void step4_ViewProductDetails() {
        Assumptions.assumeTrue(productId != null, "Product must be found first");

        givenRequest()
        .when()
            .get("/api/products/" + productId)
        .then()
            .statusCode(200)
            .body("id", equalTo(productId.intValue()))
            .body("name", notNullValue())
            .body("price", notNullValue());
    }

    @Test
    @Order(5)
    @DisplayName("Step 5: Add product to cart")
    void step5_AddToCart() {
        Assumptions.assumeTrue(userId != null && productId != null, "User and product must exist");

        String cartItemJson = String.format("""
            {
                "userId": %d,
                "productId": %d,
                "quantity": 2
            }
            """, userId, productId);

        givenRequest()
            .body(cartItemJson)
        .when()
            .post("/api/orders/cart/items")
        .then()
            .statusCode(anyOf(is(200), is(201)));

        System.out.println("Added product to cart");
    }

    @Test
    @Order(6)
    @DisplayName("Step 6: View cart")
    void step6_ViewCart() {
        Assumptions.assumeTrue(userId != null, "User must exist");

        givenRequest()
            .queryParam("userId", userId)
        .when()
            .get("/api/orders/cart")
        .then()
            .statusCode(200);
    }

    @Test
    @Order(7)
    @DisplayName("Step 7: Place order")
    void step7_PlaceOrder() {
        Assumptions.assumeTrue(userId != null, "User must exist");

        String orderJson = String.format("""
            {
                "userId": %d,
                "shippingAddress": "123 E2E Test Street, Test City, TC 12345",
                "paymentMethod": "CREDIT_CARD"
            }
            """, userId);

        orderId = givenRequest()
            .body(orderJson)
        .when()
            .post("/api/orders")
        .then()
            .statusCode(anyOf(is(200), is(201)))
            .body("id", notNullValue())
            .body("status", anyOf(equalTo("PENDING"), equalTo("CREATED")))
            .extract()
            .jsonPath()
            .getLong("id");

        System.out.println("Created order with ID: " + orderId);
    }

    @Test
    @Order(8)
    @DisplayName("Step 8: View order details")
    void step8_ViewOrderDetails() {
        Assumptions.assumeTrue(orderId != null, "Order must be placed first");

        givenRequest()
        .when()
            .get("/api/orders/" + orderId)
        .then()
            .statusCode(200)
            .body("id", equalTo(orderId.intValue()))
            .body("userId", equalTo(userId.intValue()));
    }

    @Test
    @Order(9)
    @DisplayName("Step 9: View order history")
    void step9_ViewOrderHistory() {
        Assumptions.assumeTrue(userId != null, "User must exist");

        givenRequest()
            .queryParam("userId", userId)
        .when()
            .get("/api/orders")
        .then()
            .statusCode(200)
            .body("$", hasSize(greaterThanOrEqualTo(1)));
    }

    @Test
    @Order(10)
    @DisplayName("Step 10: Cleanup - Delete user")
    void step10_Cleanup() {
        Assumptions.assumeTrue(userId != null, "User must exist");

        givenRequest()
        .when()
            .delete("/api/users/" + userId)
        .then()
            .statusCode(anyOf(is(200), is(204)));

        System.out.println("Cleanup completed");
    }
}
