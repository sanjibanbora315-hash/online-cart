-- ============================================================================
-- Online Cart - Database Schema
-- Version: 1.0
-- Description: Complete database schema for all microservices
-- ============================================================================

-- ============================================================================
-- DATABASE CREATION
-- ============================================================================

CREATE DATABASE IF NOT EXISTS user_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS product_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS order_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Grant privileges
GRANT ALL PRIVILEGES ON user_db.* TO 'onlinecart'@'%';
GRANT ALL PRIVILEGES ON product_db.* TO 'onlinecart'@'%';
GRANT ALL PRIVILEGES ON order_db.* TO 'onlinecart'@'%';
FLUSH PRIVILEGES;

-- ============================================================================
-- USER DATABASE SCHEMA
-- ============================================================================

USE user_db;

-- -----------------------------------------------------------------------------
-- Table: users
-- Description: Stores user account information
-- -----------------------------------------------------------------------------
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone VARCHAR(20),
    avatar_url VARCHAR(500),
    role ENUM('USER', 'ADMIN', 'SELLER') DEFAULT 'USER',
    status ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED', 'PENDING_VERIFICATION') DEFAULT 'PENDING_VERIFICATION',
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    last_login_at TIMESTAMP NULL,
    login_attempts INT DEFAULT 0,
    locked_until TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    UNIQUE KEY uk_users_username (username),
    UNIQUE KEY uk_users_email (email),
    INDEX idx_users_status (status),
    INDEX idx_users_role (role),
    INDEX idx_users_created_at (created_at),
    INDEX idx_users_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table: user_addresses
-- Description: Stores user shipping/billing addresses
-- -----------------------------------------------------------------------------
CREATE TABLE user_addresses (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    address_type ENUM('SHIPPING', 'BILLING', 'BOTH') DEFAULT 'BOTH',
    is_default BOOLEAN DEFAULT FALSE,
    recipient_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL DEFAULT 'India',
    landmark VARCHAR(255),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_addresses_user_id (user_id),
    INDEX idx_addresses_type (address_type),
    INDEX idx_addresses_default (is_default)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table: user_sessions
-- Description: Tracks user login sessions
-- -----------------------------------------------------------------------------
CREATE TABLE user_sessions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    session_token VARCHAR(500) NOT NULL,
    refresh_token VARCHAR(500),
    device_type VARCHAR(50),
    device_name VARCHAR(100),
    ip_address VARCHAR(45),
    user_agent TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_sessions_token (session_token(255)),
    INDEX idx_sessions_user_id (user_id),
    INDEX idx_sessions_active (is_active),
    INDEX idx_sessions_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table: user_preferences
-- Description: Stores user preferences and settings
-- -----------------------------------------------------------------------------
CREATE TABLE user_preferences (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    preference_key VARCHAR(100) NOT NULL,
    preference_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_preferences_user_key (user_id, preference_key),
    INDEX idx_preferences_key (preference_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table: password_reset_tokens
-- Description: Stores password reset tokens
-- -----------------------------------------------------------------------------
CREATE TABLE password_reset_tokens (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    token VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_reset_token (token),
    INDEX idx_reset_user_id (user_id),
    INDEX idx_reset_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- PRODUCT DATABASE SCHEMA
-- ============================================================================

USE product_db;

-- -----------------------------------------------------------------------------
-- Table: categories
-- Description: Product categories with hierarchical support
-- -----------------------------------------------------------------------------
CREATE TABLE categories (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(120) NOT NULL,
    description TEXT,
    image_url VARCHAR(500),
    parent_id BIGINT NULL,
    level INT DEFAULT 0,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    meta_title VARCHAR(200),
    meta_description VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL,
    UNIQUE KEY uk_categories_slug (slug),
    INDEX idx_categories_parent (parent_id),
    INDEX idx_categories_active (is_active),
    INDEX idx_categories_sort (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table: brands
-- Description: Product brands
-- -----------------------------------------------------------------------------
CREATE TABLE brands (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(120) NOT NULL,
    description TEXT,
    logo_url VARCHAR(500),
    website_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_brands_slug (slug),
    INDEX idx_brands_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table: products
-- Description: Main product information
-- -----------------------------------------------------------------------------
CREATE TABLE products (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    sku VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(280) NOT NULL,
    short_description VARCHAR(500),
    description TEXT,
    category_id BIGINT,
    brand_id BIGINT,

    -- Pricing
    price DECIMAL(12, 2) NOT NULL,
    compare_at_price DECIMAL(12, 2),
    cost_price DECIMAL(12, 2),
    currency VARCHAR(3) DEFAULT 'INR',

    -- Inventory
    quantity INT DEFAULT 0,
    reserved_quantity INT DEFAULT 0,
    low_stock_threshold INT DEFAULT 10,
    track_inventory BOOLEAN DEFAULT TRUE,
    allow_backorder BOOLEAN DEFAULT FALSE,

    -- Physical attributes
    weight DECIMAL(10, 3),
    weight_unit ENUM('kg', 'g', 'lb', 'oz') DEFAULT 'kg',
    length DECIMAL(10, 2),
    width DECIMAL(10, 2),
    height DECIMAL(10, 2),
    dimension_unit ENUM('cm', 'in', 'm') DEFAULT 'cm',

    -- Status
    status ENUM('DRAFT', 'ACTIVE', 'INACTIVE', 'OUT_OF_STOCK', 'DISCONTINUED') DEFAULT 'DRAFT',
    is_featured BOOLEAN DEFAULT FALSE,
    is_new BOOLEAN DEFAULT TRUE,

    -- SEO
    meta_title VARCHAR(200),
    meta_description VARCHAR(500),
    meta_keywords VARCHAR(500),

    -- Timestamps
    published_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    UNIQUE KEY uk_products_sku (sku),
    UNIQUE KEY uk_products_slug (slug),
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE SET NULL,
    INDEX idx_products_category (category_id),
    INDEX idx_products_brand (brand_id),
    INDEX idx_products_status (status),
    INDEX idx_products_price (price),
    INDEX idx_products_featured (is_featured),
    INDEX idx_products_created (created_at),
    FULLTEXT INDEX ft_products_search (name, short_description, description)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table: product_images
-- Description: Product images
-- -----------------------------------------------------------------------------
CREATE TABLE product_images (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    alt_text VARCHAR(255),
    sort_order INT DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_images_product (product_id),
    INDEX idx_images_primary (is_primary),
    INDEX idx_images_sort (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table: product_variants
-- Description: Product variants (size, color, etc.)
-- -----------------------------------------------------------------------------
CREATE TABLE product_variants (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT NOT NULL,
    sku VARCHAR(50) NOT NULL,
    name VARCHAR(255),

    -- Variant attributes (JSON for flexibility)
    attributes JSON,

    -- Pricing (if different from parent)
    price DECIMAL(12, 2),
    compare_at_price DECIMAL(12, 2),

    -- Inventory
    quantity INT DEFAULT 0,
    reserved_quantity INT DEFAULT 0,

    -- Physical attributes
    weight DECIMAL(10, 3),

    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_variants_sku (sku),
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_variants_product (product_id),
    INDEX idx_variants_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table: product_attributes
-- Description: Custom product attributes
-- -----------------------------------------------------------------------------
CREATE TABLE product_attributes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT NOT NULL,
    attribute_name VARCHAR(100) NOT NULL,
    attribute_value VARCHAR(500) NOT NULL,
    sort_order INT DEFAULT 0,

    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_attributes_product (product_id),
    INDEX idx_attributes_name (attribute_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table: product_reviews
-- Description: Customer reviews for products
-- -----------------------------------------------------------------------------
CREATE TABLE product_reviews (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    order_id BIGINT,
    rating TINYINT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(200),
    review_text TEXT,
    pros TEXT,
    cons TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    is_approved BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    helpful_count INT DEFAULT 0,
    not_helpful_count INT DEFAULT 0,
    admin_response TEXT,
    admin_responded_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_reviews_product (product_id),
    INDEX idx_reviews_user (user_id),
    INDEX idx_reviews_rating (rating),
    INDEX idx_reviews_approved (is_approved),
    INDEX idx_reviews_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table: product_review_images
-- Description: Images attached to reviews
-- -----------------------------------------------------------------------------
CREATE TABLE product_review_images (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    review_id BIGINT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (review_id) REFERENCES product_reviews(id) ON DELETE CASCADE,
    INDEX idx_review_images_review (review_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table: wishlists
-- Description: User wishlists
-- -----------------------------------------------------------------------------
CREATE TABLE wishlists (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    variant_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON DELETE SET NULL,
    UNIQUE KEY uk_wishlist_user_product (user_id, product_id, variant_id),
    INDEX idx_wishlist_user (user_id),
    INDEX idx_wishlist_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table: inventory_logs
-- Description: Inventory change history
-- -----------------------------------------------------------------------------
CREATE TABLE inventory_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT NOT NULL,
    variant_id BIGINT,
    change_type ENUM('PURCHASE', 'SALE', 'RETURN', 'ADJUSTMENT', 'RESERVATION', 'RELEASE') NOT NULL,
    quantity_change INT NOT NULL,
    previous_quantity INT NOT NULL,
    new_quantity INT NOT NULL,
    reference_type VARCHAR(50),
    reference_id BIGINT,
    notes TEXT,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON DELETE SET NULL,
    INDEX idx_inventory_product (product_id),
    INDEX idx_inventory_type (change_type),
    INDEX idx_inventory_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- ORDER DATABASE SCHEMA
-- ============================================================================

USE order_db;

-- -----------------------------------------------------------------------------
-- Table: carts
-- Description: Shopping carts
-- -----------------------------------------------------------------------------
CREATE TABLE carts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT,
    session_id VARCHAR(100),
    status ENUM('ACTIVE', 'MERGED', 'CONVERTED', 'ABANDONED') DEFAULT 'ACTIVE',
    currency VARCHAR(3) DEFAULT 'INR',
    subtotal DECIMAL(12, 2) DEFAULT 0,
    discount_total DECIMAL(12, 2) DEFAULT 0,
    tax_total DECIMAL(12, 2) DEFAULT 0,
    total DECIMAL(12, 2) DEFAULT 0,
    coupon_code VARCHAR(50),
    notes TEXT,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_carts_user (user_id),
    INDEX idx_carts_session (session_id),
    INDEX idx_carts_status (status),
    INDEX idx_carts_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table: cart_items
-- Description: Items in shopping cart
-- -----------------------------------------------------------------------------
CREATE TABLE cart_items (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    cart_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    variant_id BIGINT,
    product_name VARCHAR(255) NOT NULL,
    variant_name VARCHAR(255),
    sku VARCHAR(50) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(12, 2) NOT NULL,
    discount_amount DECIMAL(12, 2) DEFAULT 0,
    tax_amount DECIMAL(12, 2) DEFAULT 0,
    total_price DECIMAL(12, 2) NOT NULL,
    image_url VARCHAR(500),
    attributes JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE,
    UNIQUE KEY uk_cart_product (cart_id, product_id, variant_id),
    INDEX idx_cart_items_cart (cart_id),
    INDEX idx_cart_items_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table: orders
-- Description: Customer orders
-- -----------------------------------------------------------------------------
CREATE TABLE orders (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_number VARCHAR(50) NOT NULL,
    user_id BIGINT NOT NULL,

    -- Status
    status ENUM('PENDING', 'CONFIRMED', 'PROCESSING', 'SHIPPED', 'OUT_FOR_DELIVERY',
                'DELIVERED', 'CANCELLED', 'RETURNED', 'REFUNDED') DEFAULT 'PENDING',
    payment_status ENUM('PENDING', 'AUTHORIZED', 'PAID', 'PARTIALLY_REFUNDED',
                        'REFUNDED', 'FAILED') DEFAULT 'PENDING',
    fulfillment_status ENUM('UNFULFILLED', 'PARTIALLY_FULFILLED', 'FULFILLED',
                            'RETURNED') DEFAULT 'UNFULFILLED',

    -- Pricing
    currency VARCHAR(3) DEFAULT 'INR',
    subtotal DECIMAL(12, 2) NOT NULL,
    discount_total DECIMAL(12, 2) DEFAULT 0,
    shipping_total DECIMAL(12, 2) DEFAULT 0,
    tax_total DECIMAL(12, 2) DEFAULT 0,
    total DECIMAL(12, 2) NOT NULL,

    -- Payment
    payment_method VARCHAR(50),
    payment_reference VARCHAR(255),
    paid_at TIMESTAMP NULL,

    -- Shipping
    shipping_method VARCHAR(100),
    tracking_number VARCHAR(100),
    estimated_delivery_date DATE,
    shipped_at TIMESTAMP NULL,
    delivered_at TIMESTAMP NULL,

    -- Addresses (JSON for flexibility and historical accuracy)
    shipping_address JSON NOT NULL,
    billing_address JSON,

    -- Additional
    coupon_code VARCHAR(50),
    customer_notes TEXT,
    internal_notes TEXT,
    ip_address VARCHAR(45),
    user_agent VARCHAR(500),

    -- Timestamps
    confirmed_at TIMESTAMP NULL,
    cancelled_at TIMESTAMP NULL,
    cancel_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_orders_number (order_number),
    INDEX idx_orders_user (user_id),
    INDEX idx_orders_status (status),
    INDEX idx_orders_payment_status (payment_status),
    INDEX idx_orders_created (created_at),
    INDEX idx_orders_tracking (tracking_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table: order_items
-- Description: Individual items in an order
-- -----------------------------------------------------------------------------
CREATE TABLE order_items (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    variant_id BIGINT,

    -- Product snapshot
    product_name VARCHAR(255) NOT NULL,
    variant_name VARCHAR(255),
    sku VARCHAR(50) NOT NULL,
    image_url VARCHAR(500),
    attributes JSON,

    -- Pricing
    quantity INT NOT NULL,
    unit_price DECIMAL(12, 2) NOT NULL,
    discount_amount DECIMAL(12, 2) DEFAULT 0,
    tax_amount DECIMAL(12, 2) DEFAULT 0,
    total_price DECIMAL(12, 2) NOT NULL,

    -- Fulfillment
    fulfilled_quantity INT DEFAULT 0,
    returned_quantity INT DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_order_items_order (order_id),
    INDEX idx_order_items_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table: order_status_history
-- Description: Order status change history
-- -----------------------------------------------------------------------------
CREATE TABLE order_status_history (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL,
    previous_status VARCHAR(50),
    new_status VARCHAR(50) NOT NULL,
    notes TEXT,
    changed_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_status_history_order (order_id),
    INDEX idx_status_history_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table: payments
-- Description: Payment transactions
-- -----------------------------------------------------------------------------
CREATE TABLE payments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_gateway VARCHAR(50),
    transaction_id VARCHAR(255),
    gateway_response JSON,

    amount DECIMAL(12, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'INR',
    status ENUM('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'REFUNDED', 'CANCELLED') DEFAULT 'PENDING',

    paid_at TIMESTAMP NULL,
    failed_at TIMESTAMP NULL,
    failure_reason TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_payments_order (order_id),
    INDEX idx_payments_transaction (transaction_id),
    INDEX idx_payments_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table: refunds
-- Description: Refund records
-- -----------------------------------------------------------------------------
CREATE TABLE refunds (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL,
    payment_id BIGINT,
    refund_number VARCHAR(50) NOT NULL,

    amount DECIMAL(12, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'INR',
    reason TEXT,
    status ENUM('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED') DEFAULT 'PENDING',

    transaction_id VARCHAR(255),
    gateway_response JSON,

    processed_at TIMESTAMP NULL,
    processed_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE SET NULL,
    UNIQUE KEY uk_refunds_number (refund_number),
    INDEX idx_refunds_order (order_id),
    INDEX idx_refunds_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table: coupons
-- Description: Discount coupons
-- -----------------------------------------------------------------------------
CREATE TABLE coupons (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,

    discount_type ENUM('PERCENTAGE', 'FIXED_AMOUNT', 'FREE_SHIPPING') NOT NULL,
    discount_value DECIMAL(12, 2) NOT NULL,
    max_discount_amount DECIMAL(12, 2),

    min_order_amount DECIMAL(12, 2),
    max_uses INT,
    max_uses_per_user INT DEFAULT 1,
    current_uses INT DEFAULT 0,

    applicable_products JSON,
    applicable_categories JSON,
    excluded_products JSON,

    is_active BOOLEAN DEFAULT TRUE,
    starts_at TIMESTAMP,
    expires_at TIMESTAMP,

    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_coupons_code (code),
    INDEX idx_coupons_active (is_active),
    INDEX idx_coupons_dates (starts_at, expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table: coupon_usage
-- Description: Track coupon usage
-- -----------------------------------------------------------------------------
CREATE TABLE coupon_usage (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    coupon_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,
    discount_amount DECIMAL(12, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (coupon_id) REFERENCES coupons(id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_coupon_usage_coupon (coupon_id),
    INDEX idx_coupon_usage_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table: shipping_methods
-- Description: Available shipping methods
-- -----------------------------------------------------------------------------
CREATE TABLE shipping_methods (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(50) NOT NULL,
    description TEXT,
    price DECIMAL(12, 2) NOT NULL,
    free_shipping_threshold DECIMAL(12, 2),
    estimated_days_min INT,
    estimated_days_max INT,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_shipping_code (code),
    INDEX idx_shipping_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
