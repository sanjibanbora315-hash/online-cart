package com.onlinecart;

import org.junit.jupiter.api.*;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

/**
 * Integration tests for User Service.
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@DisplayName("User Service Integration Tests")
public class UserServiceIT extends BaseIntegrationTest {

    private static final String USERS_ENDPOINT = "/api/users";
    private static Long createdUserId;

    @Test
    @Order(1)
    @DisplayName("Should create a new user")
    void shouldCreateUser() {
        String userJson = """
            {
                "username": "testuser",
                "email": "testuser@example.com",
                "password": "SecurePass123!",
                "firstName": "Test",
                "lastName": "User"
            }
            """;

        createdUserId = givenRequest()
            .body(userJson)
        .when()
            .post(USERS_ENDPOINT + "/register")
        .then()
            .statusCode(anyOf(is(200), is(201)))
            .body("username", equalTo("testuser"))
            .body("email", equalTo("testuser@example.com"))
            .body("id", notNullValue())
            .extract()
            .jsonPath()
            .getLong("id");
    }

    @Test
    @Order(2)
    @DisplayName("Should get user by ID")
    void shouldGetUserById() {
        Assumptions.assumeTrue(createdUserId != null, "User must be created first");

        givenRequest()
        .when()
            .get(USERS_ENDPOINT + "/" + createdUserId)
        .then()
            .statusCode(200)
            .body("id", equalTo(createdUserId.intValue()))
            .body("username", equalTo("testuser"));
    }

    @Test
    @Order(3)
    @DisplayName("Should update user")
    void shouldUpdateUser() {
        Assumptions.assumeTrue(createdUserId != null, "User must be created first");

        String updateJson = """
            {
                "firstName": "Updated",
                "lastName": "Name"
            }
            """;

        givenRequest()
            .body(updateJson)
        .when()
            .put(USERS_ENDPOINT + "/" + createdUserId)
        .then()
            .statusCode(200)
            .body("firstName", equalTo("Updated"))
            .body("lastName", equalTo("Name"));
    }

    @Test
    @Order(4)
    @DisplayName("Should not create user with duplicate email")
    void shouldNotCreateDuplicateUser() {
        String userJson = """
            {
                "username": "testuser2",
                "email": "testuser@example.com",
                "password": "SecurePass123!",
                "firstName": "Test",
                "lastName": "User"
            }
            """;

        givenRequest()
            .body(userJson)
        .when()
            .post(USERS_ENDPOINT + "/register")
        .then()
            .statusCode(anyOf(is(400), is(409)));
    }

    @Test
    @Order(5)
    @DisplayName("Should delete user")
    void shouldDeleteUser() {
        Assumptions.assumeTrue(createdUserId != null, "User must be created first");

        givenRequest()
        .when()
            .delete(USERS_ENDPOINT + "/" + createdUserId)
        .then()
            .statusCode(anyOf(is(200), is(204)));
    }

    @Test
    @Order(6)
    @DisplayName("Should return 404 for deleted user")
    void shouldReturn404ForDeletedUser() {
        Assumptions.assumeTrue(createdUserId != null, "User must be created first");

        givenRequest()
        .when()
            .get(USERS_ENDPOINT + "/" + createdUserId)
        .then()
            .statusCode(404);
    }
}
