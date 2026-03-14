# Online Cart - API Reference

## Table of Contents

1. [Overview](#1-overview)
2. [Authentication](#2-authentication)
3. [User Service API](#3-user-service-api)
4. [Product Service API](#4-product-service-api)
5. [Order Service API](#5-order-service-api)
6. [Error Handling](#6-error-handling)
7. [Rate Limiting](#7-rate-limiting)
8. [Webhooks](#8-webhooks)

---

## 1. Overview

### Base URLs

| Environment | URL |
|-------------|-----|
| Development (Gateway) | `http://localhost:8080` |
| User Service Direct | `http://localhost:8081` |
| Product Service Direct | `http://localhost:8082` |
| Order Service Direct | `http://localhost:8083` |

### Request Headers

| Header | Required | Description |
|--------|----------|-------------|
| `Content-Type` | Yes | `application/json` |
| `Accept` | Yes | `application/json` |
| `Authorization` | Conditional | `Bearer <token>` for protected endpoints |
| `X-Request-ID` | No | UUID for request tracing |

### Response Format

All responses follow a consistent structure:

**Success Response:**
```json
{
  "data": { ... },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "requestId": "abc-123"
  }
}
```

**Paginated Response:**
```json
{
  "content": [ ... ],
  "page": 0,
  "size": 20,
  "totalElements": 100,
  "totalPages": 5
}
```

---

## 2. Authentication

### 2.1 Register User

Create a new user account.

**Endpoint:** `POST /api/users/register`

**Request Body:**
```json
{
  "username": "johndoe",
  "email": "john@example.com",
  "password": "SecurePass123!",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "+91-9876543210"
}
```

**Validation Rules:**
| Field | Rules |
|-------|-------|
| username | 3-50 characters, alphanumeric and underscore only |
| email | Valid email format, unique |
| password | Min 8 chars, must contain uppercase, lowercase, number, special char |
| firstName | Required, max 50 chars |
| lastName | Required, max 50 chars |
| phone | Optional, valid phone format |

**Response:** `201 Created`
```json
{
  "id": 1,
  "username": "johndoe",
  "email": "john@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "role": "USER",
  "status": "PENDING_VERIFICATION",
  "emailVerified": false,
  "createdAt": "2024-01-15T10:30:00Z"
}
```

---

### 2.2 Login

Authenticate and receive JWT token.

**Endpoint:** `POST /api/users/login`

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "SecurePass123!"
}
```

**Response:** `200 OK`
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
  "tokenType": "Bearer",
  "expiresIn": 3600,
  "user": {
    "id": 1,
    "username": "johndoe",
    "email": "john@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "USER"
  }
}
```

---

### 2.3 Refresh Token

Get new access token using refresh token.

**Endpoint:** `POST /api/users/refresh-token`

**Request Body:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Response:** `200 OK`
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
  "tokenType": "Bearer",
  "expiresIn": 3600
}
```

---

### 2.4 Forgot Password

Request password reset email.

**Endpoint:** `POST /api/users/forgot-password`

**Request Body:**
```json
{
  "email": "john@example.com"
}
```

**Response:** `200 OK`
```json
{
  "message": "Password reset email sent"
}
```

---

### 2.5 Reset Password

Reset password with token from email.

**Endpoint:** `POST /api/users/reset-password`

**Request Body:**
```json
{
  "token": "reset-token-from-email",
  "newPassword": "NewSecurePass123!"
}
```

**Response:** `200 OK`
```json
{
  "message": "Password reset successful"
}
```

---

## 3. User Service API

### 3.1 Get User

**Endpoint:** `GET /api/users/{id}`

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "id": 1,
  "username": "johndoe",
  "email": "john@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "+91-9876543210",
  "avatarUrl": "https://example.com/avatar.jpg",
  "role": "USER",
  "status": "ACTIVE",
  "emailVerified": true,
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-20T15:45:00Z"
}
```

---

### 3.2 Update User

**Endpoint:** `PUT /api/users/{id}`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "firstName": "Jonathan",
  "lastName": "Doe",
  "phone": "+91-9876543211",
  "avatarUrl": "https://example.com/new-avatar.jpg"
}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "username": "johndoe",
  "firstName": "Jonathan",
  "lastName": "Doe",
  "phone": "+91-9876543211",
  "updatedAt": "2024-01-25T12:00:00Z"
}
```

---

### 3.3 Delete User

Soft delete user account.

**Endpoint:** `DELETE /api/users/{id}`

**Headers:** `Authorization: Bearer <token>`

**Response:** `204 No Content`

---

### 3.4 Get User Addresses

**Endpoint:** `GET /api/users/{id}/addresses`

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "addressType": "BOTH",
    "isDefault": true,
    "recipientName": "John Doe",
    "phone": "+91-9876543210",
    "addressLine1": "123 Main Street",
    "addressLine2": "Apt 4B",
    "city": "Mumbai",
    "state": "Maharashtra",
    "postalCode": "400001",
    "country": "India",
    "landmark": "Near Central Mall"
  }
]
```

---

### 3.5 Add Address

**Endpoint:** `POST /api/users/{id}/addresses`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "addressType": "SHIPPING",
  "isDefault": false,
  "recipientName": "John Doe",
  "phone": "+91-9876543210",
  "addressLine1": "456 Office Complex",
  "addressLine2": "Floor 5",
  "city": "Mumbai",
  "state": "Maharashtra",
  "postalCode": "400051",
  "country": "India",
  "landmark": "Tech Park"
}
```

**Response:** `201 Created`

---

### 3.6 Update Address

**Endpoint:** `PUT /api/users/{userId}/addresses/{addressId}`

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

---

### 3.7 Delete Address

**Endpoint:** `DELETE /api/users/{userId}/addresses/{addressId}`

**Headers:** `Authorization: Bearer <token>`

**Response:** `204 No Content`

---

## 4. Product Service API

### 4.1 List Products

**Endpoint:** `GET /api/products`

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| page | integer | 0 | Page number (0-indexed) |
| size | integer | 20 | Items per page (max 100) |
| sort | string | createdAt | Sort field (prefix with - for desc) |
| category | integer | - | Filter by category ID |
| brand | integer | - | Filter by brand ID |
| minPrice | number | - | Minimum price |
| maxPrice | number | - | Maximum price |
| status | string | ACTIVE | Product status |
| featured | boolean | - | Filter featured products |
| inStock | boolean | - | Filter in-stock products |

**Example:** `GET /api/products?category=10&minPrice=1000&maxPrice=50000&sort=-price&page=0&size=20`

**Response:** `200 OK`
```json
{
  "content": [
    {
      "id": 1,
      "sku": "PHONE-001",
      "name": "iPhone 15 Pro",
      "slug": "iphone-15-pro",
      "shortDescription": "Latest iPhone with A17 Pro chip",
      "price": 134900.00,
      "compareAtPrice": 139900.00,
      "quantity": 50,
      "status": "ACTIVE",
      "isFeatured": true,
      "isNew": true,
      "primaryImage": "https://images.example.com/iphone15pro.jpg",
      "category": {
        "id": 10,
        "name": "Smartphones",
        "slug": "smartphones"
      },
      "brand": {
        "id": 1,
        "name": "Apple",
        "slug": "apple"
      },
      "averageRating": 4.8,
      "reviewCount": 156
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 150,
  "totalPages": 8
}
```

---

### 4.2 Get Product Details

**Endpoint:** `GET /api/products/{id}`

**Response:** `200 OK`
```json
{
  "id": 1,
  "sku": "PHONE-001",
  "name": "iPhone 15 Pro",
  "slug": "iphone-15-pro",
  "shortDescription": "Latest iPhone with A17 Pro chip",
  "description": "The iPhone 15 Pro features a titanium design...",
  "price": 134900.00,
  "compareAtPrice": 139900.00,
  "quantity": 50,
  "lowStockThreshold": 10,
  "status": "ACTIVE",
  "isFeatured": true,
  "isNew": true,
  "weight": 0.187,
  "weightUnit": "kg",
  "category": {
    "id": 10,
    "name": "Smartphones",
    "slug": "smartphones"
  },
  "brand": {
    "id": 1,
    "name": "Apple",
    "slug": "apple",
    "logoUrl": "https://example.com/apple-logo.png"
  },
  "images": [
    {
      "id": 1,
      "imageUrl": "https://images.example.com/iphone15pro-1.jpg",
      "thumbnailUrl": "https://images.example.com/iphone15pro-1-thumb.jpg",
      "altText": "iPhone 15 Pro front view",
      "isPrimary": true
    },
    {
      "id": 2,
      "imageUrl": "https://images.example.com/iphone15pro-2.jpg",
      "thumbnailUrl": "https://images.example.com/iphone15pro-2-thumb.jpg",
      "altText": "iPhone 15 Pro back view",
      "isPrimary": false
    }
  ],
  "variants": [
    {
      "id": 1,
      "sku": "PHONE-001-128-NAT",
      "name": "128GB Natural Titanium",
      "attributes": {
        "storage": "128GB",
        "color": "Natural Titanium"
      },
      "price": 134900.00,
      "quantity": 15
    },
    {
      "id": 2,
      "sku": "PHONE-001-256-NAT",
      "name": "256GB Natural Titanium",
      "attributes": {
        "storage": "256GB",
        "color": "Natural Titanium"
      },
      "price": 144900.00,
      "quantity": 12
    }
  ],
  "attributes": [
    {"name": "Display", "value": "6.1\" Super Retina XDR OLED"},
    {"name": "Chip", "value": "A17 Pro"},
    {"name": "Camera", "value": "48MP Main + 12MP Ultra Wide + 12MP Telephoto"},
    {"name": "Battery", "value": "Up to 23 hours video playback"}
  ],
  "averageRating": 4.8,
  "reviewCount": 156,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

---

### 4.3 Search Products

Full-text search across product names and descriptions.

**Endpoint:** `GET /api/products/search`

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| q | string | Yes | Search query (min 2 chars) |
| page | integer | No | Page number |
| size | integer | No | Items per page |
| category | integer | No | Filter by category |

**Example:** `GET /api/products/search?q=iphone&category=10`

**Response:** Same as List Products

---

### 4.4 Create Product

**Endpoint:** `POST /api/products`

**Headers:** `Authorization: Bearer <token>` (Admin/Seller only)

**Request Body:**
```json
{
  "sku": "PHONE-005",
  "name": "New Smartphone",
  "slug": "new-smartphone",
  "shortDescription": "Latest smartphone model",
  "description": "Full product description...",
  "categoryId": 10,
  "brandId": 2,
  "price": 49999.00,
  "compareAtPrice": 54999.00,
  "costPrice": 35000.00,
  "quantity": 100,
  "lowStockThreshold": 10,
  "weight": 0.180,
  "weightUnit": "kg",
  "status": "DRAFT",
  "isFeatured": false
}
```

**Response:** `201 Created`

---

### 4.5 Update Product

**Endpoint:** `PUT /api/products/{id}`

**Headers:** `Authorization: Bearer <token>` (Admin/Seller only)

**Request Body:**
```json
{
  "name": "Updated Product Name",
  "price": 45999.00,
  "quantity": 150,
  "status": "ACTIVE",
  "isFeatured": true
}
```

**Response:** `200 OK`

---

### 4.6 Update Inventory

**Endpoint:** `PATCH /api/products/{id}/inventory`

**Headers:** `Authorization: Bearer <token>` (Admin/Seller only)

**Request Body:**
```json
{
  "quantity": 50,
  "changeType": "PURCHASE",
  "notes": "Stock replenishment from supplier"
}
```

**Change Types:** `PURCHASE`, `SALE`, `RETURN`, `ADJUSTMENT`, `RESERVATION`, `RELEASE`

**Response:** `200 OK`
```json
{
  "productId": 1,
  "previousQuantity": 100,
  "newQuantity": 150,
  "changeType": "PURCHASE",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

### 4.7 Delete Product

Soft delete a product.

**Endpoint:** `DELETE /api/products/{id}`

**Headers:** `Authorization: Bearer <token>` (Admin only)

**Response:** `204 No Content`

---

### 4.8 Get Categories

**Endpoint:** `GET /api/categories`

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| parentId | integer | Filter by parent category |
| includeInactive | boolean | Include inactive categories |

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "name": "Electronics",
    "slug": "electronics",
    "description": "Electronic devices and gadgets",
    "imageUrl": "https://example.com/electronics.jpg",
    "parentId": null,
    "level": 0,
    "isActive": true,
    "children": [
      {
        "id": 10,
        "name": "Smartphones",
        "slug": "smartphones",
        "parentId": 1,
        "level": 1,
        "children": []
      },
      {
        "id": 11,
        "name": "Laptops",
        "slug": "laptops",
        "parentId": 1,
        "level": 1,
        "children": []
      }
    ]
  }
]
```

---

### 4.9 Get Product Reviews

**Endpoint:** `GET /api/products/{productId}/reviews`

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| page | integer | Page number |
| size | integer | Items per page |
| rating | integer | Filter by rating (1-5) |
| sort | string | Sort by: createdAt, rating, helpful |

**Response:** `200 OK`
```json
{
  "content": [
    {
      "id": 1,
      "userId": 3,
      "userName": "John D.",
      "rating": 5,
      "title": "Best iPhone ever!",
      "reviewText": "The A17 Pro chip is incredibly fast...",
      "pros": "Fast, Great camera, Premium build",
      "cons": "Expensive, Battery could be better",
      "isVerifiedPurchase": true,
      "helpfulCount": 45,
      "createdAt": "2024-01-10T15:30:00Z"
    }
  ],
  "averageRating": 4.8,
  "totalReviews": 156,
  "ratingDistribution": {
    "5": 120,
    "4": 25,
    "3": 8,
    "2": 2,
    "1": 1
  },
  "page": 0,
  "size": 10,
  "totalPages": 16
}
```

---

### 4.10 Create Review

**Endpoint:** `POST /api/products/{productId}/reviews`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "rating": 5,
  "title": "Excellent product!",
  "reviewText": "This is the best purchase I've made...",
  "pros": "Great quality, Fast delivery",
  "cons": "Slightly expensive"
}
```

**Response:** `201 Created`

---

## 5. Order Service API

### 5.1 Get Cart

**Endpoint:** `GET /api/orders/cart?userId={userId}`

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "id": 1,
  "userId": 3,
  "items": [
    {
      "id": 1,
      "productId": 1,
      "variantId": 1,
      "productName": "iPhone 15 Pro",
      "variantName": "128GB Natural Titanium",
      "sku": "PHONE-001-128-NAT",
      "imageUrl": "https://images.example.com/iphone15pro.jpg",
      "quantity": 1,
      "unitPrice": 134900.00,
      "totalPrice": 134900.00,
      "inStock": true
    },
    {
      "id": 2,
      "productId": 8,
      "variantId": null,
      "productName": "AirPods Pro 2",
      "variantName": null,
      "sku": "AUDIO-001",
      "imageUrl": "https://images.example.com/airpods.jpg",
      "quantity": 1,
      "unitPrice": 24900.00,
      "totalPrice": 24900.00,
      "inStock": true
    }
  ],
  "subtotal": 159800.00,
  "discountTotal": 0.00,
  "taxTotal": 0.00,
  "total": 159800.00,
  "itemCount": 2,
  "couponCode": null,
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

---

### 5.2 Add to Cart

**Endpoint:** `POST /api/orders/cart/items`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "userId": 3,
  "productId": 1,
  "variantId": 1,
  "quantity": 1
}
```

**Response:** `201 Created` - Returns updated cart

---

### 5.3 Update Cart Item

**Endpoint:** `PUT /api/orders/cart/items/{itemId}`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "quantity": 2
}
```

**Response:** `200 OK` - Returns updated cart

---

### 5.4 Remove Cart Item

**Endpoint:** `DELETE /api/orders/cart/items/{itemId}`

**Headers:** `Authorization: Bearer <token>`

**Response:** `204 No Content`

---

### 5.5 Apply Coupon

**Endpoint:** `POST /api/orders/cart/coupon`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "userId": 3,
  "couponCode": "WELCOME10"
}
```

**Response:** `200 OK` - Returns updated cart with discount applied

---

### 5.6 Clear Cart

**Endpoint:** `DELETE /api/orders/cart?userId={userId}`

**Headers:** `Authorization: Bearer <token>`

**Response:** `204 No Content`

---

### 5.7 Create Order

Create order from cart.

**Endpoint:** `POST /api/orders`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "userId": 3,
  "shippingAddressId": 1,
  "billingAddressId": 1,
  "shippingMethod": "EXPRESS",
  "paymentMethod": "CREDIT_CARD",
  "couponCode": "WELCOME10",
  "customerNotes": "Please deliver after 5 PM"
}
```

**Response:** `201 Created`
```json
{
  "id": 1,
  "orderNumber": "ORD-2024-000001",
  "userId": 3,
  "status": "PENDING",
  "paymentStatus": "PENDING",
  "fulfillmentStatus": "UNFULFILLED",
  "subtotal": 159800.00,
  "discountTotal": 15980.00,
  "shippingTotal": 0.00,
  "taxTotal": 0.00,
  "total": 143820.00,
  "shippingMethod": "EXPRESS",
  "paymentMethod": "CREDIT_CARD",
  "estimatedDeliveryDate": "2024-01-18",
  "createdAt": "2024-01-15T10:30:00Z"
}
```

---

### 5.8 List Orders

**Endpoint:** `GET /api/orders`

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| userId | integer | Filter by user (required for non-admin) |
| status | string | Filter by status |
| page | integer | Page number |
| size | integer | Items per page |
| fromDate | date | Orders from date |
| toDate | date | Orders to date |

**Response:** `200 OK`
```json
{
  "content": [
    {
      "id": 1,
      "orderNumber": "ORD-2024-000001",
      "status": "DELIVERED",
      "paymentStatus": "PAID",
      "total": 134900.00,
      "itemCount": 1,
      "createdAt": "2024-01-10T10:30:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 5,
  "totalPages": 1
}
```

---

### 5.9 Get Order Details

**Endpoint:** `GET /api/orders/{id}`

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "id": 1,
  "orderNumber": "ORD-2024-000001",
  "userId": 3,
  "status": "DELIVERED",
  "paymentStatus": "PAID",
  "fulfillmentStatus": "FULFILLED",
  "subtotal": 134900.00,
  "discountTotal": 0.00,
  "shippingTotal": 0.00,
  "taxTotal": 0.00,
  "total": 134900.00,
  "paymentMethod": "CREDIT_CARD",
  "shippingMethod": "EXPRESS",
  "trackingNumber": "TRK123456789",
  "estimatedDeliveryDate": "2024-01-13",
  "shippingAddress": {
    "name": "John Doe",
    "phone": "+91-9876543210",
    "addressLine1": "123 Main Street",
    "city": "Mumbai",
    "state": "Maharashtra",
    "postalCode": "400001",
    "country": "India"
  },
  "items": [
    {
      "id": 1,
      "productId": 1,
      "productName": "iPhone 15 Pro",
      "variantName": "128GB Natural Titanium",
      "sku": "PHONE-001-128-NAT",
      "imageUrl": "https://images.example.com/iphone15pro.jpg",
      "quantity": 1,
      "unitPrice": 134900.00,
      "totalPrice": 134900.00
    }
  ],
  "statusHistory": [
    {
      "status": "PENDING",
      "notes": "Order placed",
      "createdAt": "2024-01-10T10:30:00Z"
    },
    {
      "status": "CONFIRMED",
      "notes": "Payment confirmed",
      "createdAt": "2024-01-10T10:35:00Z"
    },
    {
      "status": "SHIPPED",
      "notes": "Order shipped via Express Delivery",
      "createdAt": "2024-01-11T14:00:00Z"
    },
    {
      "status": "DELIVERED",
      "notes": "Order delivered",
      "createdAt": "2024-01-13T11:30:00Z"
    }
  ],
  "createdAt": "2024-01-10T10:30:00Z",
  "updatedAt": "2024-01-13T11:30:00Z"
}
```

---

### 5.10 Update Order Status

**Endpoint:** `PATCH /api/orders/{id}/status`

**Headers:** `Authorization: Bearer <token>` (Admin only)

**Request Body:**
```json
{
  "status": "SHIPPED",
  "trackingNumber": "TRK123456789",
  "notes": "Shipped via BlueDart Express"
}
```

**Status Transitions:**
- `PENDING` → `CONFIRMED` | `CANCELLED`
- `CONFIRMED` → `PROCESSING` | `CANCELLED`
- `PROCESSING` → `SHIPPED` | `CANCELLED`
- `SHIPPED` → `OUT_FOR_DELIVERY` | `DELIVERED`
- `DELIVERED` → `RETURNED`

**Response:** `200 OK`

---

### 5.11 Cancel Order

**Endpoint:** `DELETE /api/orders/{id}`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "reason": "Changed my mind"
}
```

**Note:** Can only cancel orders with status `PENDING`, `CONFIRMED`, or `PROCESSING`

**Response:** `200 OK`

---

## 6. Error Handling

### Error Response Format

```json
{
  "error": "VALIDATION_ERROR",
  "message": "Invalid request data",
  "status": 400,
  "timestamp": "2024-01-15T10:30:00Z",
  "path": "/api/users/register",
  "details": [
    {
      "field": "email",
      "message": "must be a valid email address"
    },
    {
      "field": "password",
      "message": "must be at least 8 characters"
    }
  ]
}
```

### Error Codes

| HTTP Status | Error Code | Description |
|-------------|------------|-------------|
| 400 | VALIDATION_ERROR | Invalid request data |
| 400 | INVALID_OPERATION | Operation not allowed |
| 401 | UNAUTHORIZED | Missing or invalid token |
| 403 | FORBIDDEN | Insufficient permissions |
| 404 | NOT_FOUND | Resource not found |
| 409 | CONFLICT | Resource already exists |
| 422 | UNPROCESSABLE_ENTITY | Business rule violation |
| 429 | TOO_MANY_REQUESTS | Rate limit exceeded |
| 500 | INTERNAL_ERROR | Server error |
| 503 | SERVICE_UNAVAILABLE | Service temporarily unavailable |

---

## 7. Rate Limiting

| Endpoint Type | Limit | Window |
|---------------|-------|--------|
| Authentication | 10 requests | 1 minute |
| Read operations | 100 requests | 1 minute |
| Write operations | 30 requests | 1 minute |
| Search | 20 requests | 1 minute |

**Rate Limit Headers:**
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1705312200
```

---

## 8. Webhooks

### Available Events

| Event | Description |
|-------|-------------|
| `order.created` | New order placed |
| `order.confirmed` | Order payment confirmed |
| `order.shipped` | Order shipped |
| `order.delivered` | Order delivered |
| `order.cancelled` | Order cancelled |
| `user.registered` | New user registered |
| `product.low_stock` | Product below threshold |

### Webhook Payload

```json
{
  "event": "order.created",
  "timestamp": "2024-01-15T10:30:00Z",
  "data": {
    "orderId": 1,
    "orderNumber": "ORD-2024-000001",
    "userId": 3,
    "total": 134900.00
  }
}
```

### Webhook Security

All webhooks include a signature header:
```
X-Webhook-Signature: sha256=abc123...
```

Verify by computing HMAC-SHA256 of the payload with your webhook secret.

---

## Appendix

### A. Order Statuses

| Status | Description |
|--------|-------------|
| PENDING | Order placed, awaiting payment |
| CONFIRMED | Payment confirmed |
| PROCESSING | Order being prepared |
| SHIPPED | Order shipped |
| OUT_FOR_DELIVERY | Order out for delivery |
| DELIVERED | Order delivered |
| CANCELLED | Order cancelled |
| RETURNED | Order returned |
| REFUNDED | Payment refunded |

### B. Payment Methods

| Code | Description |
|------|-------------|
| CREDIT_CARD | Credit card payment |
| DEBIT_CARD | Debit card payment |
| UPI | UPI payment |
| NET_BANKING | Net banking |
| WALLET | Digital wallet |
| COD | Cash on delivery |

### C. Shipping Methods

| Code | Price | Delivery Time |
|------|-------|---------------|
| STANDARD | ₹99 | 5-7 days |
| EXPRESS | ₹199 | 2-3 days |
| SAME_DAY | ₹399 | Same day |
| FREE | ₹0 | 5-7 days (orders > ₹999) |
