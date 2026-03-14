# Online Cart - Database Schema Documentation

## 1. Overview

The Online Cart platform uses a **Database-per-Service** pattern with MySQL 8.0. Each microservice has its own dedicated database ensuring loose coupling and independent scaling.

| Database | Service | Tables |
|----------|---------|--------|
| user_db | User Service | 5 tables |
| product_db | Product Service | 9 tables |
| order_db | Order Service | 10 tables |

---

## 2. Database: user_db

### 2.1 Entity Relationship Diagram

```
┌─────────────────┐       ┌───────────────────┐
│     users       │───┬───│  user_addresses   │
└─────────────────┘   │   └───────────────────┘
         │            │
         │            │   ┌───────────────────┐
         ├────────────┼───│  user_sessions    │
         │            │   └───────────────────┘
         │            │
         │            │   ┌───────────────────┐
         ├────────────┼───│ user_preferences  │
         │            │   └───────────────────┘
         │            │
         │            │   ┌───────────────────────┐
         └────────────┴───│ password_reset_tokens │
                          └───────────────────────┘
```

### 2.2 Table: users

Primary table for user account information.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK, AUTO_INCREMENT | Unique identifier |
| username | VARCHAR(50) | UNIQUE, NOT NULL | Login username |
| email | VARCHAR(100) | UNIQUE, NOT NULL | User email |
| password | VARCHAR(255) | NOT NULL | BCrypt hashed password |
| first_name | VARCHAR(50) | | First name |
| last_name | VARCHAR(50) | | Last name |
| phone | VARCHAR(20) | | Phone number |
| avatar_url | VARCHAR(500) | | Profile picture URL |
| role | ENUM | DEFAULT 'USER' | USER, ADMIN, SELLER |
| status | ENUM | DEFAULT 'PENDING_VERIFICATION' | Account status |
| email_verified | BOOLEAN | DEFAULT FALSE | Email verification status |
| phone_verified | BOOLEAN | DEFAULT FALSE | Phone verification status |
| last_login_at | TIMESTAMP | | Last login timestamp |
| login_attempts | INT | DEFAULT 0 | Failed login attempts |
| locked_until | TIMESTAMP | | Account lock expiry |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Creation time |
| updated_at | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Last update time |
| deleted_at | TIMESTAMP | | Soft delete timestamp |

**Indexes:**
- `uk_users_username` - UNIQUE on username
- `uk_users_email` - UNIQUE on email
- `idx_users_status` - INDEX on status
- `idx_users_role` - INDEX on role

### 2.3 Table: user_addresses

User shipping and billing addresses.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK, AUTO_INCREMENT | Unique identifier |
| user_id | BIGINT | FK → users.id | User reference |
| address_type | ENUM | DEFAULT 'BOTH' | SHIPPING, BILLING, BOTH |
| is_default | BOOLEAN | DEFAULT FALSE | Default address flag |
| recipient_name | VARCHAR(100) | NOT NULL | Recipient name |
| phone | VARCHAR(20) | | Contact phone |
| address_line1 | VARCHAR(255) | NOT NULL | Street address |
| address_line2 | VARCHAR(255) | | Apt/Suite/Floor |
| city | VARCHAR(100) | NOT NULL | City |
| state | VARCHAR(100) | | State/Province |
| postal_code | VARCHAR(20) | NOT NULL | ZIP/Postal code |
| country | VARCHAR(100) | DEFAULT 'India' | Country |
| landmark | VARCHAR(255) | | Nearby landmark |
| latitude | DECIMAL(10,8) | | GPS latitude |
| longitude | DECIMAL(11,8) | | GPS longitude |

### 2.4 Table: user_sessions

Active user login sessions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK | Session ID |
| user_id | BIGINT | FK → users.id | User reference |
| session_token | VARCHAR(500) | UNIQUE | JWT access token |
| refresh_token | VARCHAR(500) | | JWT refresh token |
| device_type | VARCHAR(50) | | mobile, desktop, tablet |
| device_name | VARCHAR(100) | | Device identifier |
| ip_address | VARCHAR(45) | | Client IP (IPv6 compatible) |
| user_agent | TEXT | | Browser user agent |
| is_active | BOOLEAN | DEFAULT TRUE | Session active status |
| expires_at | TIMESTAMP | NOT NULL | Session expiry |

### 2.5 Table: user_preferences

User settings and preferences (key-value store).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK | Preference ID |
| user_id | BIGINT | FK → users.id | User reference |
| preference_key | VARCHAR(100) | NOT NULL | Setting name |
| preference_value | TEXT | | Setting value |

**Common Preference Keys:**
- `newsletter_subscribed` - true/false
- `preferred_language` - en, hi, etc.
- `currency` - INR, USD, etc.
- `dark_mode` - true/false
- `notification_email` - true/false
- `notification_sms` - true/false

### 2.6 Table: password_reset_tokens

Password reset request tokens.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK | Token ID |
| user_id | BIGINT | FK → users.id | User reference |
| token | VARCHAR(255) | UNIQUE, NOT NULL | Reset token |
| expires_at | TIMESTAMP | NOT NULL | Token expiry |
| used_at | TIMESTAMP | | When token was used |

---

## 3. Database: product_db

### 3.1 Entity Relationship Diagram

```
┌─────────────┐
│ categories  │◄─────────┐ (self-reference)
└──────┬──────┘          │
       │                 │
       │ parent_id ──────┘
       │
       ▼
┌─────────────┐     ┌─────────────┐
│  products   │─────│   brands    │
└──────┬──────┘     └─────────────┘
       │
       ├───────────────┬───────────────┬───────────────┐
       │               │               │               │
       ▼               ▼               ▼               ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│product_images│ │product_variants│ │product_reviews│ │product_attributes│
└──────────────┘ └──────────────┘ └───────┬──────┘ └──────────────┘
                                          │
                                          ▼
                                  ┌───────────────────┐
                                  │product_review_images│
                                  └───────────────────┘

┌─────────────┐     ┌─────────────────┐
│  wishlists  │     │ inventory_logs  │
└─────────────┘     └─────────────────┘
```

### 3.2 Table: categories

Product categories with hierarchical support.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK | Category ID |
| name | VARCHAR(100) | NOT NULL | Category name |
| slug | VARCHAR(120) | UNIQUE, NOT NULL | URL-friendly slug |
| description | TEXT | | Category description |
| image_url | VARCHAR(500) | | Category image |
| parent_id | BIGINT | FK → categories.id | Parent category |
| level | INT | DEFAULT 0 | Hierarchy level (0=root) |
| sort_order | INT | DEFAULT 0 | Display order |
| is_active | BOOLEAN | DEFAULT TRUE | Active status |
| meta_title | VARCHAR(200) | | SEO title |
| meta_description | VARCHAR(500) | | SEO description |

### 3.3 Table: brands

Product brands/manufacturers.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK | Brand ID |
| name | VARCHAR(100) | NOT NULL | Brand name |
| slug | VARCHAR(120) | UNIQUE, NOT NULL | URL-friendly slug |
| description | TEXT | | Brand description |
| logo_url | VARCHAR(500) | | Brand logo |
| website_url | VARCHAR(500) | | Official website |
| is_active | BOOLEAN | DEFAULT TRUE | Active status |

### 3.4 Table: products

Main product information.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK | Product ID |
| sku | VARCHAR(50) | UNIQUE, NOT NULL | Stock keeping unit |
| name | VARCHAR(255) | NOT NULL | Product name |
| slug | VARCHAR(280) | UNIQUE, NOT NULL | URL-friendly slug |
| short_description | VARCHAR(500) | | Brief description |
| description | TEXT | | Full description |
| category_id | BIGINT | FK → categories.id | Category reference |
| brand_id | BIGINT | FK → brands.id | Brand reference |
| price | DECIMAL(12,2) | NOT NULL | Selling price |
| compare_at_price | DECIMAL(12,2) | | Original/MRP price |
| cost_price | DECIMAL(12,2) | | Cost price |
| currency | VARCHAR(3) | DEFAULT 'INR' | Currency code |
| quantity | INT | DEFAULT 0 | Stock quantity |
| reserved_quantity | INT | DEFAULT 0 | Reserved for orders |
| low_stock_threshold | INT | DEFAULT 10 | Low stock alert level |
| track_inventory | BOOLEAN | DEFAULT TRUE | Track stock levels |
| allow_backorder | BOOLEAN | DEFAULT FALSE | Allow backorders |
| weight | DECIMAL(10,3) | | Product weight |
| weight_unit | ENUM | DEFAULT 'kg' | kg, g, lb, oz |
| length | DECIMAL(10,2) | | Length dimension |
| width | DECIMAL(10,2) | | Width dimension |
| height | DECIMAL(10,2) | | Height dimension |
| dimension_unit | ENUM | DEFAULT 'cm' | cm, in, m |
| status | ENUM | DEFAULT 'DRAFT' | DRAFT, ACTIVE, INACTIVE, OUT_OF_STOCK, DISCONTINUED |
| is_featured | BOOLEAN | DEFAULT FALSE | Featured product flag |
| is_new | BOOLEAN | DEFAULT TRUE | New arrival flag |
| meta_title | VARCHAR(200) | | SEO title |
| meta_description | VARCHAR(500) | | SEO description |
| meta_keywords | VARCHAR(500) | | SEO keywords |
| published_at | TIMESTAMP | | Publish date |
| deleted_at | TIMESTAMP | | Soft delete timestamp |

**Indexes:**
- Full-text index on `name, short_description, description`
- Index on `category_id`, `brand_id`, `status`, `price`

### 3.5 Table: product_images

Product gallery images.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK | Image ID |
| product_id | BIGINT | FK → products.id | Product reference |
| image_url | VARCHAR(500) | NOT NULL | Full image URL |
| thumbnail_url | VARCHAR(500) | | Thumbnail URL |
| alt_text | VARCHAR(255) | | Image alt text |
| sort_order | INT | DEFAULT 0 | Display order |
| is_primary | BOOLEAN | DEFAULT FALSE | Primary image flag |

### 3.6 Table: product_variants

Product variations (size, color, etc.).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK | Variant ID |
| product_id | BIGINT | FK → products.id | Product reference |
| sku | VARCHAR(50) | UNIQUE, NOT NULL | Variant SKU |
| name | VARCHAR(255) | | Variant name |
| attributes | JSON | | Variant attributes |
| price | DECIMAL(12,2) | | Override price |
| compare_at_price | DECIMAL(12,2) | | Override compare price |
| quantity | INT | DEFAULT 0 | Variant stock |
| reserved_quantity | INT | DEFAULT 0 | Reserved quantity |
| weight | DECIMAL(10,3) | | Override weight |
| image_url | VARCHAR(500) | | Variant image |
| is_active | BOOLEAN | DEFAULT TRUE | Active status |

**Example attributes JSON:**
```json
{
  "size": "M",
  "color": "Blue",
  "material": "Cotton"
}
```

### 3.7 Table: product_attributes

Custom product specifications.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK | Attribute ID |
| product_id | BIGINT | FK → products.id | Product reference |
| attribute_name | VARCHAR(100) | NOT NULL | Attribute name |
| attribute_value | VARCHAR(500) | NOT NULL | Attribute value |
| sort_order | INT | DEFAULT 0 | Display order |

### 3.8 Table: product_reviews

Customer product reviews.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK | Review ID |
| product_id | BIGINT | FK → products.id | Product reference |
| user_id | BIGINT | NOT NULL | Reviewer user ID |
| order_id | BIGINT | | Order reference |
| rating | TINYINT | CHECK (1-5) | Star rating |
| title | VARCHAR(200) | | Review title |
| review_text | TEXT | | Review content |
| pros | TEXT | | Product pros |
| cons | TEXT | | Product cons |
| is_verified_purchase | BOOLEAN | DEFAULT FALSE | Verified buyer flag |
| is_approved | BOOLEAN | DEFAULT FALSE | Moderation status |
| is_featured | BOOLEAN | DEFAULT FALSE | Featured review |
| helpful_count | INT | DEFAULT 0 | Helpful votes |
| not_helpful_count | INT | DEFAULT 0 | Not helpful votes |
| admin_response | TEXT | | Admin reply |
| admin_responded_at | TIMESTAMP | | Admin reply time |

### 3.9 Table: wishlists

User product wishlists.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK | Wishlist item ID |
| user_id | BIGINT | NOT NULL | User reference |
| product_id | BIGINT | FK → products.id | Product reference |
| variant_id | BIGINT | FK → product_variants.id | Variant reference |

**Unique Constraint:** (user_id, product_id, variant_id)

### 3.10 Table: inventory_logs

Inventory change audit trail.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK | Log ID |
| product_id | BIGINT | FK → products.id | Product reference |
| variant_id | BIGINT | FK → product_variants.id | Variant reference |
| change_type | ENUM | NOT NULL | PURCHASE, SALE, RETURN, ADJUSTMENT, RESERVATION, RELEASE |
| quantity_change | INT | NOT NULL | Change amount (+/-) |
| previous_quantity | INT | NOT NULL | Quantity before |
| new_quantity | INT | NOT NULL | Quantity after |
| reference_type | VARCHAR(50) | | Reference entity type |
| reference_id | BIGINT | | Reference entity ID |
| notes | TEXT | | Change notes |
| created_by | BIGINT | | User who made change |

---

## 4. Database: order_db

### 4.1 Entity Relationship Diagram

```
┌─────────────┐
│   carts     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ cart_items  │
└─────────────┘


┌─────────────┐     ┌─────────────────────┐
│   orders    │─────│ order_status_history│
└──────┬──────┘     └─────────────────────┘
       │
       ├───────────────┬───────────────┐
       │               │               │
       ▼               ▼               ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│ order_items │ │  payments   │ │   refunds   │
└─────────────┘ └─────────────┘ └─────────────┘


┌─────────────┐     ┌─────────────────┐
│   coupons   │─────│  coupon_usage   │
└─────────────┘     └─────────────────┘


┌──────────────────┐
│ shipping_methods │
└──────────────────┘
```

### 4.2 Table: carts

Shopping carts.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK | Cart ID |
| user_id | BIGINT | | User reference (null for guest) |
| session_id | VARCHAR(100) | | Guest session ID |
| status | ENUM | DEFAULT 'ACTIVE' | ACTIVE, MERGED, CONVERTED, ABANDONED |
| currency | VARCHAR(3) | DEFAULT 'INR' | Currency code |
| subtotal | DECIMAL(12,2) | DEFAULT 0 | Items subtotal |
| discount_total | DECIMAL(12,2) | DEFAULT 0 | Total discounts |
| tax_total | DECIMAL(12,2) | DEFAULT 0 | Total tax |
| total | DECIMAL(12,2) | DEFAULT 0 | Grand total |
| coupon_code | VARCHAR(50) | | Applied coupon |
| notes | TEXT | | Cart notes |
| expires_at | TIMESTAMP | | Cart expiry |

### 4.3 Table: cart_items

Items in shopping cart.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK | Cart item ID |
| cart_id | BIGINT | FK → carts.id | Cart reference |
| product_id | BIGINT | NOT NULL | Product reference |
| variant_id | BIGINT | | Variant reference |
| product_name | VARCHAR(255) | NOT NULL | Product name snapshot |
| variant_name | VARCHAR(255) | | Variant name snapshot |
| sku | VARCHAR(50) | NOT NULL | SKU snapshot |
| quantity | INT | DEFAULT 1 | Quantity |
| unit_price | DECIMAL(12,2) | NOT NULL | Price per unit |
| discount_amount | DECIMAL(12,2) | DEFAULT 0 | Item discount |
| tax_amount | DECIMAL(12,2) | DEFAULT 0 | Item tax |
| total_price | DECIMAL(12,2) | NOT NULL | Line total |
| image_url | VARCHAR(500) | | Product image |
| attributes | JSON | | Variant attributes |

### 4.4 Table: orders

Customer orders.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK | Order ID |
| order_number | VARCHAR(50) | UNIQUE, NOT NULL | Display order number |
| user_id | BIGINT | NOT NULL | Customer user ID |
| status | ENUM | DEFAULT 'PENDING' | Order status |
| payment_status | ENUM | DEFAULT 'PENDING' | Payment status |
| fulfillment_status | ENUM | DEFAULT 'UNFULFILLED' | Fulfillment status |
| currency | VARCHAR(3) | DEFAULT 'INR' | Currency |
| subtotal | DECIMAL(12,2) | NOT NULL | Items subtotal |
| discount_total | DECIMAL(12,2) | DEFAULT 0 | Total discounts |
| shipping_total | DECIMAL(12,2) | DEFAULT 0 | Shipping cost |
| tax_total | DECIMAL(12,2) | DEFAULT 0 | Total tax |
| total | DECIMAL(12,2) | NOT NULL | Grand total |
| payment_method | VARCHAR(50) | | Payment method |
| payment_reference | VARCHAR(255) | | Payment transaction ID |
| paid_at | TIMESTAMP | | Payment timestamp |
| shipping_method | VARCHAR(100) | | Shipping method |
| tracking_number | VARCHAR(100) | | Shipment tracking |
| estimated_delivery_date | DATE | | Expected delivery |
| shipped_at | TIMESTAMP | | Ship timestamp |
| delivered_at | TIMESTAMP | | Delivery timestamp |
| shipping_address | JSON | NOT NULL | Shipping address snapshot |
| billing_address | JSON | | Billing address snapshot |
| coupon_code | VARCHAR(50) | | Applied coupon |
| customer_notes | TEXT | | Customer notes |
| internal_notes | TEXT | | Admin notes |
| ip_address | VARCHAR(45) | | Client IP |
| user_agent | VARCHAR(500) | | Browser info |
| confirmed_at | TIMESTAMP | | Confirmation timestamp |
| cancelled_at | TIMESTAMP | | Cancellation timestamp |
| cancel_reason | TEXT | | Cancellation reason |

**Order Status Values:**
- `PENDING` - Awaiting payment
- `CONFIRMED` - Payment confirmed
- `PROCESSING` - Being prepared
- `SHIPPED` - In transit
- `OUT_FOR_DELIVERY` - Out for delivery
- `DELIVERED` - Delivered
- `CANCELLED` - Cancelled
- `RETURNED` - Returned
- `REFUNDED` - Refunded

### 4.5 Table: order_items

Order line items.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK | Order item ID |
| order_id | BIGINT | FK → orders.id | Order reference |
| product_id | BIGINT | NOT NULL | Product reference |
| variant_id | BIGINT | | Variant reference |
| product_name | VARCHAR(255) | NOT NULL | Product name snapshot |
| variant_name | VARCHAR(255) | | Variant name snapshot |
| sku | VARCHAR(50) | NOT NULL | SKU snapshot |
| image_url | VARCHAR(500) | | Product image |
| attributes | JSON | | Variant attributes |
| quantity | INT | NOT NULL | Quantity ordered |
| unit_price | DECIMAL(12,2) | NOT NULL | Price per unit |
| discount_amount | DECIMAL(12,2) | DEFAULT 0 | Item discount |
| tax_amount | DECIMAL(12,2) | DEFAULT 0 | Item tax |
| total_price | DECIMAL(12,2) | NOT NULL | Line total |
| fulfilled_quantity | INT | DEFAULT 0 | Quantity shipped |
| returned_quantity | INT | DEFAULT 0 | Quantity returned |

### 4.6 Table: order_status_history

Order status change audit trail.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK | History ID |
| order_id | BIGINT | FK → orders.id | Order reference |
| previous_status | VARCHAR(50) | | Previous status |
| new_status | VARCHAR(50) | NOT NULL | New status |
| notes | TEXT | | Status change notes |
| changed_by | BIGINT | | User who changed |

### 4.7 Table: payments

Payment transactions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK | Payment ID |
| order_id | BIGINT | FK → orders.id | Order reference |
| payment_method | VARCHAR(50) | NOT NULL | Payment method |
| payment_gateway | VARCHAR(50) | | Gateway used |
| transaction_id | VARCHAR(255) | | Gateway transaction ID |
| gateway_response | JSON | | Full gateway response |
| amount | DECIMAL(12,2) | NOT NULL | Payment amount |
| currency | VARCHAR(3) | DEFAULT 'INR' | Currency |
| status | ENUM | DEFAULT 'PENDING' | PENDING, PROCESSING, COMPLETED, FAILED, REFUNDED, CANCELLED |
| paid_at | TIMESTAMP | | Payment completion time |
| failed_at | TIMESTAMP | | Failure timestamp |
| failure_reason | TEXT | | Failure reason |

### 4.8 Table: refunds

Refund records.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK | Refund ID |
| order_id | BIGINT | FK → orders.id | Order reference |
| payment_id | BIGINT | FK → payments.id | Original payment |
| refund_number | VARCHAR(50) | UNIQUE, NOT NULL | Refund reference |
| amount | DECIMAL(12,2) | NOT NULL | Refund amount |
| currency | VARCHAR(3) | DEFAULT 'INR' | Currency |
| reason | TEXT | | Refund reason |
| status | ENUM | DEFAULT 'PENDING' | PENDING, PROCESSING, COMPLETED, FAILED |
| transaction_id | VARCHAR(255) | | Gateway transaction ID |
| gateway_response | JSON | | Gateway response |
| processed_at | TIMESTAMP | | Processing timestamp |
| processed_by | BIGINT | | Admin who processed |

### 4.9 Table: coupons

Discount coupons.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK | Coupon ID |
| code | VARCHAR(50) | UNIQUE, NOT NULL | Coupon code |
| name | VARCHAR(100) | NOT NULL | Coupon name |
| description | TEXT | | Coupon description |
| discount_type | ENUM | NOT NULL | PERCENTAGE, FIXED_AMOUNT, FREE_SHIPPING |
| discount_value | DECIMAL(12,2) | NOT NULL | Discount value |
| max_discount_amount | DECIMAL(12,2) | | Max discount cap |
| min_order_amount | DECIMAL(12,2) | | Minimum order value |
| max_uses | INT | | Total usage limit |
| max_uses_per_user | INT | DEFAULT 1 | Per-user limit |
| current_uses | INT | DEFAULT 0 | Current usage count |
| applicable_products | JSON | | Product IDs (null = all) |
| applicable_categories | JSON | | Category IDs |
| excluded_products | JSON | | Excluded product IDs |
| is_active | BOOLEAN | DEFAULT TRUE | Active status |
| starts_at | TIMESTAMP | | Valid from |
| expires_at | TIMESTAMP | | Valid until |
| created_by | BIGINT | | Creator user ID |

### 4.10 Table: coupon_usage

Coupon usage tracking.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK | Usage ID |
| coupon_id | BIGINT | FK → coupons.id | Coupon reference |
| user_id | BIGINT | NOT NULL | User who used |
| order_id | BIGINT | FK → orders.id | Order reference |
| discount_amount | DECIMAL(12,2) | NOT NULL | Actual discount applied |

### 4.11 Table: shipping_methods

Available shipping options.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PK | Method ID |
| name | VARCHAR(100) | NOT NULL | Display name |
| code | VARCHAR(50) | UNIQUE, NOT NULL | Method code |
| description | TEXT | | Method description |
| price | DECIMAL(12,2) | NOT NULL | Shipping cost |
| free_shipping_threshold | DECIMAL(12,2) | | Free shipping above |
| estimated_days_min | INT | | Min delivery days |
| estimated_days_max | INT | | Max delivery days |
| is_active | BOOLEAN | DEFAULT TRUE | Active status |
| sort_order | INT | DEFAULT 0 | Display order |

---

## 5. Seed Data Summary

### 5.1 Users (10 records)

| Username | Email | Role | Password |
|----------|-------|------|----------|
| admin | admin@onlinecart.com | ADMIN | Password123! |
| seller1 | seller@onlinecart.com | SELLER | Password123! |
| john_doe | john@example.com | USER | Password123! |
| jane_smith | jane@example.com | USER | Password123! |
| mike_wilson | mike@example.com | USER | Password123! |
| sarah_jones | sarah@example.com | USER | Password123! |
| david_brown | david@example.com | USER | Password123! |
| emily_davis | emily@example.com | USER | Password123! |
| testuser | testuser@example.com | USER | Password123! |
| guest_user | guest@example.com | USER | Password123! |

### 5.2 Categories (23 records)

**Parent Categories:**
- Electronics, Clothing, Home & Garden, Books, Sports & Outdoors, Beauty & Health

**Subcategories:**
- Electronics: Smartphones, Laptops, Audio, Cameras, Wearables, Gaming
- Clothing: Men's, Women's, Kids', Footwear, Accessories
- Home & Garden: Furniture, Kitchen, Decor, Garden
- Books: Fiction, Non-Fiction, Technology, Children's

### 5.3 Brands (15 records)

Apple, Samsung, Sony, Nike, Adidas, Dell, HP, Bose, Canon, IKEA, Penguin, OnePlus, Xiaomi, Boat, Puma

### 5.4 Products (28 records)

| Category | Products |
|----------|----------|
| Smartphones | iPhone 15 Pro, Samsung Galaxy S24 Ultra, OnePlus 12, Xiaomi 14 Pro |
| Laptops | MacBook Pro 16", Dell XPS 15, HP Spectre x360 |
| Audio | AirPods Pro 2, Sony WH-1000XM5, Bose QuietComfort Ultra, Boat Airdopes 441 |
| Cameras | Canon EOS R6 Mark II |
| Wearables | Apple Watch Series 9, Samsung Galaxy Watch 6 |
| Gaming | PlayStation 5 |
| Clothing | Nike Dri-FIT T-Shirt, Adidas Track Pants, Nike Air Max Dress |
| Footwear | Nike Air Max 270, Adidas Ultraboost 23, Puma RS-X |
| Furniture | IKEA MALM Bed, IKEA KALLAX Shelf |
| Kitchen | Instant Pot Duo |
| Books | Clean Code, The Pragmatic Programmer, Atomic Habits, The Alchemist |

### 5.5 Sample Orders (5 records)

Orders with various statuses: DELIVERED, SHIPPED, PROCESSING, PENDING

### 5.6 Coupons (5 records)

| Code | Type | Value |
|------|------|-------|
| WELCOME10 | Percentage | 10% off |
| FLAT500 | Fixed | ₹500 off |
| FREESHIP | Free Shipping | Free shipping |
| SUMMER25 | Percentage | 25% off |
| ELECTRONICS15 | Percentage | 15% off electronics |

---

## 6. Database Maintenance

### 6.1 Backup Commands

```bash
# Backup all databases
mysqldump -u root -p --all-databases > full_backup.sql

# Backup individual database
mysqldump -u root -p user_db > user_db_backup.sql
mysqldump -u root -p product_db > product_db_backup.sql
mysqldump -u root -p order_db > order_db_backup.sql
```

### 6.2 Restore Commands

```bash
# Restore from backup
mysql -u root -p < full_backup.sql

# Restore individual database
mysql -u root -p user_db < user_db_backup.sql
```

### 6.3 Useful Queries

```sql
-- Check database sizes
SELECT
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables
GROUP BY table_schema;

-- Check table sizes
SELECT
    table_name,
    ROUND(data_length / 1024 / 1024, 2) AS 'Data (MB)',
    ROUND(index_length / 1024 / 1024, 2) AS 'Index (MB)'
FROM information_schema.tables
WHERE table_schema = 'product_db'
ORDER BY data_length DESC;

-- Check slow queries
SELECT * FROM mysql.slow_log ORDER BY start_time DESC LIMIT 10;
```
