-- ============================================================================
-- Online Cart - Seed Data
-- Version: 1.0
-- Description: Initial seed data for development and testing
-- ============================================================================

-- ============================================================================
-- USER DATABASE SEED DATA
-- ============================================================================

USE user_db;

-- -----------------------------------------------------------------------------
-- Users (Password: Password123! - BCrypt hashed)
-- -----------------------------------------------------------------------------
INSERT INTO users (username, email, password, first_name, last_name, phone, role, status, email_verified) VALUES
('admin', 'admin@onlinecart.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IjqQBrkOGDS/ghKoBtl7yLwMr/0z6a', 'System', 'Administrator', '+91-9000000001', 'ADMIN', 'ACTIVE', TRUE),
('seller1', 'seller@onlinecart.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IjqQBrkOGDS/ghKoBtl7yLwMr/0z6a', 'John', 'Seller', '+91-9000000002', 'SELLER', 'ACTIVE', TRUE),
('john_doe', 'john@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IjqQBrkOGDS/ghKoBtl7yLwMr/0z6a', 'John', 'Doe', '+91-9876543210', 'USER', 'ACTIVE', TRUE),
('jane_smith', 'jane@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IjqQBrkOGDS/ghKoBtl7yLwMr/0z6a', 'Jane', 'Smith', '+91-9876543211', 'USER', 'ACTIVE', TRUE),
('mike_wilson', 'mike@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IjqQBrkOGDS/ghKoBtl7yLwMr/0z6a', 'Mike', 'Wilson', '+91-9876543212', 'USER', 'ACTIVE', TRUE),
('sarah_jones', 'sarah@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IjqQBrkOGDS/ghKoBtl7yLwMr/0z6a', 'Sarah', 'Jones', '+91-9876543213', 'USER', 'ACTIVE', TRUE),
('david_brown', 'david@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IjqQBrkOGDS/ghKoBtl7yLwMr/0z6a', 'David', 'Brown', '+91-9876543214', 'USER', 'ACTIVE', TRUE),
('emily_davis', 'emily@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IjqQBrkOGDS/ghKoBtl7yLwMr/0z6a', 'Emily', 'Davis', '+91-9876543215', 'USER', 'ACTIVE', TRUE),
('testuser', 'testuser@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IjqQBrkOGDS/ghKoBtl7yLwMr/0z6a', 'Test', 'User', '+91-9876543216', 'USER', 'ACTIVE', TRUE),
('guest_user', 'guest@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IjqQBrkOGDS/ghKoBtl7yLwMr/0z6a', 'Guest', 'User', '+91-9876543217', 'USER', 'PENDING_VERIFICATION', FALSE);

-- -----------------------------------------------------------------------------
-- User Addresses
-- -----------------------------------------------------------------------------
INSERT INTO user_addresses (user_id, address_type, is_default, recipient_name, phone, address_line1, address_line2, city, state, postal_code, country, landmark) VALUES
-- John Doe's addresses
(3, 'BOTH', TRUE, 'John Doe', '+91-9876543210', '123 Main Street', 'Apt 4B', 'Mumbai', 'Maharashtra', '400001', 'India', 'Near Central Mall'),
(3, 'SHIPPING', FALSE, 'John Doe', '+91-9876543210', '456 Office Complex', 'Floor 5', 'Mumbai', 'Maharashtra', '400051', 'India', 'Tech Park'),

-- Jane Smith's addresses
(4, 'BOTH', TRUE, 'Jane Smith', '+91-9876543211', '789 Park Avenue', 'Building C', 'Bangalore', 'Karnataka', '560001', 'India', 'Opposite City Park'),

-- Mike Wilson's addresses
(5, 'BOTH', TRUE, 'Mike Wilson', '+91-9876543212', '321 Lake View Road', NULL, 'Chennai', 'Tamil Nadu', '600001', 'India', 'Near Lake'),

-- Sarah Jones's addresses
(6, 'SHIPPING', TRUE, 'Sarah Jones', '+91-9876543213', '567 Hill Station Road', 'Villa 12', 'Pune', 'Maharashtra', '411001', 'India', NULL),
(6, 'BILLING', FALSE, 'Sarah Jones', '+91-9876543213', '890 Business District', 'Tower A', 'Pune', 'Maharashtra', '411045', 'India', 'IT Park'),

-- David Brown's addresses
(7, 'BOTH', TRUE, 'David Brown', '+91-9876543214', '234 Green Valley', 'House 5', 'Hyderabad', 'Telangana', '500001', 'India', 'Near Metro Station'),

-- Test user address
(9, 'BOTH', TRUE, 'Test User', '+91-9876543216', '999 Test Street', 'Test Building', 'Delhi', 'Delhi', '110001', 'India', 'Test Landmark');

-- -----------------------------------------------------------------------------
-- User Preferences
-- -----------------------------------------------------------------------------
INSERT INTO user_preferences (user_id, preference_key, preference_value) VALUES
(3, 'newsletter_subscribed', 'true'),
(3, 'preferred_language', 'en'),
(3, 'currency', 'INR'),
(4, 'newsletter_subscribed', 'true'),
(4, 'preferred_language', 'en'),
(5, 'newsletter_subscribed', 'false'),
(6, 'preferred_language', 'en'),
(6, 'dark_mode', 'true');


-- ============================================================================
-- PRODUCT DATABASE SEED DATA
-- ============================================================================

USE product_db;

-- -----------------------------------------------------------------------------
-- Categories
-- -----------------------------------------------------------------------------
INSERT INTO categories (id, name, slug, description, parent_id, level, sort_order, is_active) VALUES
-- Parent Categories
(1, 'Electronics', 'electronics', 'Electronic devices and gadgets', NULL, 0, 1, TRUE),
(2, 'Clothing', 'clothing', 'Apparel and fashion items', NULL, 0, 2, TRUE),
(3, 'Home & Garden', 'home-garden', 'Home decor and garden supplies', NULL, 0, 3, TRUE),
(4, 'Books', 'books', 'Books and publications', NULL, 0, 4, TRUE),
(5, 'Sports & Outdoors', 'sports-outdoors', 'Sports equipment and outdoor gear', NULL, 0, 5, TRUE),
(6, 'Beauty & Health', 'beauty-health', 'Beauty products and health items', NULL, 0, 6, TRUE),

-- Electronics Subcategories
(10, 'Smartphones', 'smartphones', 'Mobile phones and accessories', 1, 1, 1, TRUE),
(11, 'Laptops', 'laptops', 'Laptops and notebooks', 1, 1, 2, TRUE),
(12, 'Audio', 'audio', 'Headphones, speakers, and audio equipment', 1, 1, 3, TRUE),
(13, 'Cameras', 'cameras', 'Digital cameras and photography equipment', 1, 1, 4, TRUE),
(14, 'Wearables', 'wearables', 'Smartwatches and fitness trackers', 1, 1, 5, TRUE),
(15, 'Gaming', 'gaming', 'Gaming consoles and accessories', 1, 1, 6, TRUE),

-- Clothing Subcategories
(20, 'Men\'s Clothing', 'mens-clothing', 'Clothing for men', 2, 1, 1, TRUE),
(21, 'Women\'s Clothing', 'womens-clothing', 'Clothing for women', 2, 1, 2, TRUE),
(22, 'Kids\' Clothing', 'kids-clothing', 'Clothing for children', 2, 1, 3, TRUE),
(23, 'Footwear', 'footwear', 'Shoes and sandals', 2, 1, 4, TRUE),
(24, 'Accessories', 'fashion-accessories', 'Fashion accessories', 2, 1, 5, TRUE),

-- Home & Garden Subcategories
(30, 'Furniture', 'furniture', 'Home furniture', 3, 1, 1, TRUE),
(31, 'Kitchen', 'kitchen', 'Kitchen appliances and accessories', 3, 1, 2, TRUE),
(32, 'Decor', 'decor', 'Home decor items', 3, 1, 3, TRUE),
(33, 'Garden', 'garden', 'Garden tools and plants', 3, 1, 4, TRUE),

-- Books Subcategories
(40, 'Fiction', 'fiction', 'Fiction books', 4, 1, 1, TRUE),
(41, 'Non-Fiction', 'non-fiction', 'Non-fiction books', 4, 1, 2, TRUE),
(42, 'Technology', 'technology-books', 'Technology and programming books', 4, 1, 3, TRUE),
(43, 'Children\'s Books', 'childrens-books', 'Books for children', 4, 1, 4, TRUE);

-- -----------------------------------------------------------------------------
-- Brands
-- -----------------------------------------------------------------------------
INSERT INTO brands (id, name, slug, description, is_active) VALUES
(1, 'Apple', 'apple', 'Apple Inc. - Premium electronics and software', TRUE),
(2, 'Samsung', 'samsung', 'Samsung Electronics - Leading technology company', TRUE),
(3, 'Sony', 'sony', 'Sony Corporation - Electronics and entertainment', TRUE),
(4, 'Nike', 'nike', 'Nike Inc. - Sports apparel and footwear', TRUE),
(5, 'Adidas', 'adidas', 'Adidas AG - Sports apparel and footwear', TRUE),
(6, 'Dell', 'dell', 'Dell Technologies - Computers and peripherals', TRUE),
(7, 'HP', 'hp', 'HP Inc. - Computers and printers', TRUE),
(8, 'Bose', 'bose', 'Bose Corporation - Audio equipment', TRUE),
(9, 'Canon', 'canon', 'Canon Inc. - Cameras and imaging', TRUE),
(10, 'IKEA', 'ikea', 'IKEA - Furniture and home accessories', TRUE),
(11, 'Penguin', 'penguin', 'Penguin Random House - Book publisher', TRUE),
(12, 'OnePlus', 'oneplus', 'OnePlus Technology - Smartphones', TRUE),
(13, 'Xiaomi', 'xiaomi', 'Xiaomi Corporation - Electronics', TRUE),
(14, 'Boat', 'boat', 'Boat - Audio and wearables', TRUE),
(15, 'Puma', 'puma', 'Puma SE - Sports apparel', TRUE);

-- -----------------------------------------------------------------------------
-- Products
-- -----------------------------------------------------------------------------
INSERT INTO products (id, sku, name, slug, short_description, description, category_id, brand_id, price, compare_at_price, quantity, low_stock_threshold, status, is_featured, is_new) VALUES
-- Smartphones
(1, 'PHONE-001', 'iPhone 15 Pro', 'iphone-15-pro', 'Latest iPhone with A17 Pro chip', 'The iPhone 15 Pro features a titanium design, A17 Pro chip, advanced camera system with 48MP main camera, and USB-C connectivity. Experience the most powerful iPhone ever.', 10, 1, 134900.00, 139900.00, 50, 10, 'ACTIVE', TRUE, TRUE),
(2, 'PHONE-002', 'Samsung Galaxy S24 Ultra', 'samsung-galaxy-s24-ultra', 'Premium Android flagship', 'Samsung Galaxy S24 Ultra with 200MP camera, S Pen support, 6.8" Dynamic AMOLED display, and powerful Snapdragon processor.', 10, 2, 129999.00, 134999.00, 45, 10, 'ACTIVE', TRUE, TRUE),
(3, 'PHONE-003', 'OnePlus 12', 'oneplus-12', 'Flagship killer smartphone', 'OnePlus 12 with Snapdragon 8 Gen 3, 50MP Hasselblad camera, 100W fast charging, and stunning 2K display.', 10, 12, 64999.00, 69999.00, 80, 15, 'ACTIVE', FALSE, TRUE),
(4, 'PHONE-004', 'Xiaomi 14 Pro', 'xiaomi-14-pro', 'Pro-grade smartphone', 'Xiaomi 14 Pro with Leica optics, Snapdragon 8 Gen 3, 120W HyperCharge, and premium ceramic design.', 10, 13, 59999.00, NULL, 60, 10, 'ACTIVE', FALSE, TRUE),

-- Laptops
(5, 'LAPTOP-001', 'MacBook Pro 16"', 'macbook-pro-16', 'Pro laptop for professionals', 'MacBook Pro 16" with M3 Pro chip, 18GB RAM, 512GB SSD, Liquid Retina XDR display. Perfect for creative professionals.', 11, 1, 249900.00, 259900.00, 25, 5, 'ACTIVE', TRUE, TRUE),
(6, 'LAPTOP-002', 'Dell XPS 15', 'dell-xps-15', 'Premium Windows ultrabook', 'Dell XPS 15 with Intel Core i7, 16GB RAM, 512GB SSD, NVIDIA RTX 4050, stunning OLED display.', 11, 6, 164990.00, 179990.00, 30, 5, 'ACTIVE', TRUE, FALSE),
(7, 'LAPTOP-003', 'HP Spectre x360', 'hp-spectre-x360', 'Convertible premium laptop', 'HP Spectre x360 2-in-1 laptop with Intel Core i7, 16GB RAM, 1TB SSD, touch display, and premium design.', 11, 7, 142990.00, NULL, 20, 5, 'ACTIVE', FALSE, FALSE),

-- Audio
(8, 'AUDIO-001', 'AirPods Pro 2', 'airpods-pro-2', 'Premium wireless earbuds', 'AirPods Pro 2nd generation with Active Noise Cancellation, Adaptive Audio, and MagSafe charging case.', 12, 1, 24900.00, 26900.00, 100, 20, 'ACTIVE', TRUE, FALSE),
(9, 'AUDIO-002', 'Sony WH-1000XM5', 'sony-wh-1000xm5', 'Industry-leading noise cancelling', 'Sony WH-1000XM5 wireless headphones with best-in-class noise cancellation, 30hr battery, and premium sound.', 12, 3, 29990.00, 34990.00, 40, 10, 'ACTIVE', TRUE, FALSE),
(10, 'AUDIO-003', 'Bose QuietComfort Ultra', 'bose-qc-ultra', 'Immersive audio experience', 'Bose QuietComfort Ultra headphones with spatial audio, world-class noise cancellation, and all-day comfort.', 12, 8, 34900.00, NULL, 35, 10, 'ACTIVE', FALSE, TRUE),
(11, 'AUDIO-004', 'Boat Airdopes 441', 'boat-airdopes-441', 'Budget wireless earbuds', 'Boat Airdopes 441 TWS earbuds with 30hr playback, IPX7 water resistance, and IWP technology.', 12, 14, 1499.00, 2990.00, 200, 30, 'ACTIVE', FALSE, FALSE),

-- Cameras
(12, 'CAM-001', 'Canon EOS R6 Mark II', 'canon-eos-r6-mark-ii', 'Professional mirrorless camera', 'Canon EOS R6 Mark II with 24.2MP sensor, 4K 60fps video, advanced autofocus, and in-body stabilization.', 13, 9, 239990.00, NULL, 15, 3, 'ACTIVE', TRUE, TRUE),

-- Wearables
(13, 'WEAR-001', 'Apple Watch Series 9', 'apple-watch-series-9', 'Most advanced Apple Watch', 'Apple Watch Series 9 with S9 chip, Double Tap gesture, brighter display, and advanced health features.', 14, 1, 44900.00, 49900.00, 60, 10, 'ACTIVE', TRUE, TRUE),
(14, 'WEAR-002', 'Samsung Galaxy Watch 6', 'samsung-galaxy-watch-6', 'Premium Android smartwatch', 'Samsung Galaxy Watch 6 with BioActive sensor, sleep coaching, and Wear OS integration.', 14, 2, 32999.00, 36999.00, 45, 10, 'ACTIVE', FALSE, TRUE),

-- Gaming
(15, 'GAME-001', 'PlayStation 5', 'playstation-5', 'Next-gen gaming console', 'PlayStation 5 console with ultra-high speed SSD, 4K gaming, ray tracing, and DualSense controller.', 15, 3, 54990.00, NULL, 20, 5, 'ACTIVE', TRUE, FALSE),

-- Men's Clothing
(16, 'CLOTH-M-001', 'Nike Dri-FIT T-Shirt', 'nike-dri-fit-tshirt', 'Performance training tee', 'Nike Dri-FIT technology keeps you dry and comfortable during workouts. Classic fit, breathable fabric.', 20, 4, 1795.00, 2295.00, 150, 20, 'ACTIVE', FALSE, FALSE),
(17, 'CLOTH-M-002', 'Adidas Track Pants', 'adidas-track-pants', 'Classic training pants', 'Adidas Essentials 3-Stripes track pants with comfortable fit and iconic design.', 20, 5, 2499.00, 2999.00, 100, 15, 'ACTIVE', FALSE, FALSE),

-- Women's Clothing
(18, 'CLOTH-W-001', 'Nike Air Max Dress', 'nike-air-max-dress', 'Sporty casual dress', 'Comfortable Nike dress perfect for casual outings. Breathable fabric with stylish design.', 21, 4, 3495.00, 4495.00, 60, 10, 'ACTIVE', FALSE, TRUE),

-- Footwear
(19, 'FOOT-001', 'Nike Air Max 270', 'nike-air-max-270', 'Iconic lifestyle sneakers', 'Nike Air Max 270 with large Air unit, comfortable foam, and modern design. Perfect for everyday wear.', 23, 4, 13995.00, 15995.00, 80, 15, 'ACTIVE', TRUE, FALSE),
(20, 'FOOT-002', 'Adidas Ultraboost 23', 'adidas-ultraboost-23', 'Premium running shoes', 'Adidas Ultraboost 23 with responsive BOOST midsole, Primeknit upper, and Continental rubber outsole.', 23, 5, 16999.00, 18999.00, 50, 10, 'ACTIVE', TRUE, TRUE),
(21, 'FOOT-003', 'Puma RS-X', 'puma-rs-x', 'Retro-inspired sneakers', 'Puma RS-X with chunky design, RS cushioning, and bold color combinations.', 23, 15, 8999.00, 10999.00, 70, 15, 'ACTIVE', FALSE, FALSE),

-- Furniture
(22, 'FURN-001', 'IKEA MALM Bed Frame', 'ikea-malm-bed-frame', 'Modern bed frame', 'Clean, minimalist MALM bed frame in white. Queen size with slatted bed base included.', 30, 10, 15990.00, NULL, 25, 5, 'ACTIVE', FALSE, FALSE),
(23, 'FURN-002', 'IKEA KALLAX Shelf', 'ikea-kallax-shelf', 'Versatile storage solution', 'KALLAX shelf unit 4x4 configuration. Perfect for books, storage boxes, or display items.', 30, 10, 8990.00, NULL, 40, 8, 'ACTIVE', FALSE, FALSE),

-- Kitchen
(24, 'KITCH-001', 'Instant Pot Duo 7-in-1', 'instant-pot-duo', 'Multi-use pressure cooker', 'Instant Pot Duo 7-in-1 electric pressure cooker, slow cooker, rice cooker, steamer, and more.', 31, NULL, 8999.00, 12999.00, 55, 10, 'ACTIVE', TRUE, FALSE),

-- Books
(25, 'BOOK-001', 'Clean Code', 'clean-code', 'A handbook of agile software craftsmanship', 'Clean Code by Robert C. Martin. Learn to write clean, maintainable code. A must-read for developers.', 42, 11, 499.00, 599.00, 200, 30, 'ACTIVE', TRUE, FALSE),
(26, 'BOOK-002', 'The Pragmatic Programmer', 'pragmatic-programmer', 'Your journey to mastery', 'The Pragmatic Programmer 20th Anniversary Edition. Timeless advice for modern developers.', 42, 11, 549.00, 699.00, 150, 25, 'ACTIVE', TRUE, FALSE),
(27, 'BOOK-003', 'Atomic Habits', 'atomic-habits', 'Tiny changes, remarkable results', 'Atomic Habits by James Clear. Learn the science of building good habits and breaking bad ones.', 41, 11, 399.00, 499.00, 300, 50, 'ACTIVE', TRUE, FALSE),
(28, 'BOOK-004', 'The Alchemist', 'the-alchemist', 'A fable about following your dream', 'The Alchemist by Paulo Coelho. A magical story about listening to your heart and following your dreams.', 40, 11, 299.00, 350.00, 250, 40, 'ACTIVE', FALSE, FALSE);

-- -----------------------------------------------------------------------------
-- Product Images
-- -----------------------------------------------------------------------------
INSERT INTO product_images (product_id, image_url, thumbnail_url, alt_text, sort_order, is_primary) VALUES
-- iPhone 15 Pro
(1, 'https://images.example.com/iphone15pro-1.jpg', 'https://images.example.com/iphone15pro-1-thumb.jpg', 'iPhone 15 Pro front view', 1, TRUE),
(1, 'https://images.example.com/iphone15pro-2.jpg', 'https://images.example.com/iphone15pro-2-thumb.jpg', 'iPhone 15 Pro back view', 2, FALSE),
(1, 'https://images.example.com/iphone15pro-3.jpg', 'https://images.example.com/iphone15pro-3-thumb.jpg', 'iPhone 15 Pro side view', 3, FALSE),

-- Samsung Galaxy S24 Ultra
(2, 'https://images.example.com/s24ultra-1.jpg', 'https://images.example.com/s24ultra-1-thumb.jpg', 'Samsung Galaxy S24 Ultra front', 1, TRUE),
(2, 'https://images.example.com/s24ultra-2.jpg', 'https://images.example.com/s24ultra-2-thumb.jpg', 'Samsung Galaxy S24 Ultra back', 2, FALSE),

-- MacBook Pro
(5, 'https://images.example.com/macbook-pro-1.jpg', 'https://images.example.com/macbook-pro-1-thumb.jpg', 'MacBook Pro open', 1, TRUE),
(5, 'https://images.example.com/macbook-pro-2.jpg', 'https://images.example.com/macbook-pro-2-thumb.jpg', 'MacBook Pro closed', 2, FALSE);

-- -----------------------------------------------------------------------------
-- Product Variants
-- -----------------------------------------------------------------------------
INSERT INTO product_variants (product_id, sku, name, attributes, price, quantity, is_active) VALUES
-- iPhone 15 Pro variants
(1, 'PHONE-001-128-NAT', 'iPhone 15 Pro 128GB Natural Titanium', '{"storage": "128GB", "color": "Natural Titanium"}', 134900.00, 15, TRUE),
(1, 'PHONE-001-256-NAT', 'iPhone 15 Pro 256GB Natural Titanium', '{"storage": "256GB", "color": "Natural Titanium"}', 144900.00, 12, TRUE),
(1, 'PHONE-001-128-BLU', 'iPhone 15 Pro 128GB Blue Titanium', '{"storage": "128GB", "color": "Blue Titanium"}', 134900.00, 10, TRUE),
(1, 'PHONE-001-256-BLK', 'iPhone 15 Pro 256GB Black Titanium', '{"storage": "256GB", "color": "Black Titanium"}', 144900.00, 13, TRUE),

-- Nike T-Shirt variants
(16, 'CLOTH-M-001-S-BLK', 'Nike Dri-FIT T-Shirt Small Black', '{"size": "S", "color": "Black"}', 1795.00, 30, TRUE),
(16, 'CLOTH-M-001-M-BLK', 'Nike Dri-FIT T-Shirt Medium Black', '{"size": "M", "color": "Black"}', 1795.00, 40, TRUE),
(16, 'CLOTH-M-001-L-BLK', 'Nike Dri-FIT T-Shirt Large Black', '{"size": "L", "color": "Black"}', 1795.00, 35, TRUE),
(16, 'CLOTH-M-001-M-WHT', 'Nike Dri-FIT T-Shirt Medium White', '{"size": "M", "color": "White"}', 1795.00, 25, TRUE),
(16, 'CLOTH-M-001-L-WHT', 'Nike Dri-FIT T-Shirt Large White', '{"size": "L", "color": "White"}', 1795.00, 20, TRUE),

-- Nike Air Max 270 variants
(19, 'FOOT-001-8-BLK', 'Nike Air Max 270 Size 8 Black', '{"size": "UK 8", "color": "Black/White"}', 13995.00, 15, TRUE),
(19, 'FOOT-001-9-BLK', 'Nike Air Max 270 Size 9 Black', '{"size": "UK 9", "color": "Black/White"}', 13995.00, 20, TRUE),
(19, 'FOOT-001-10-BLK', 'Nike Air Max 270 Size 10 Black', '{"size": "UK 10", "color": "Black/White"}', 13995.00, 18, TRUE);

-- -----------------------------------------------------------------------------
-- Product Attributes
-- -----------------------------------------------------------------------------
INSERT INTO product_attributes (product_id, attribute_name, attribute_value, sort_order) VALUES
-- iPhone 15 Pro
(1, 'Display', '6.1" Super Retina XDR OLED', 1),
(1, 'Chip', 'A17 Pro', 2),
(1, 'Camera', '48MP Main + 12MP Ultra Wide + 12MP Telephoto', 3),
(1, 'Battery', 'Up to 23 hours video playback', 4),
(1, 'Connectivity', '5G, Wi-Fi 6E, Bluetooth 5.3', 5),

-- MacBook Pro
(5, 'Display', '16.2" Liquid Retina XDR', 1),
(5, 'Chip', 'Apple M3 Pro', 2),
(5, 'Memory', '18GB Unified Memory', 3),
(5, 'Storage', '512GB SSD', 4),
(5, 'Battery', 'Up to 22 hours', 5),

-- Clean Code Book
(25, 'Author', 'Robert C. Martin', 1),
(25, 'Pages', '464', 2),
(25, 'Publisher', 'Pearson', 3),
(25, 'ISBN', '978-0132350884', 4);

-- -----------------------------------------------------------------------------
-- Product Reviews
-- -----------------------------------------------------------------------------
INSERT INTO product_reviews (product_id, user_id, rating, title, review_text, is_verified_purchase, is_approved, helpful_count) VALUES
-- iPhone 15 Pro reviews
(1, 3, 5, 'Best iPhone ever!', 'The A17 Pro chip is incredibly fast. Camera quality is outstanding, especially in low light. Titanium design feels premium.', TRUE, TRUE, 45),
(1, 4, 4, 'Great phone, minor issues', 'Excellent performance and camera. Only complaint is the battery could be better. Still the best phone I have owned.', TRUE, TRUE, 23),
(1, 5, 5, 'Worth every penny', 'Upgraded from iPhone 12 and the difference is remarkable. The display is gorgeous and the camera is professional grade.', TRUE, TRUE, 18),

-- MacBook Pro reviews
(5, 3, 5, 'Perfect for developers', 'M3 Pro handles all my development tasks effortlessly. Battery life is incredible. Best laptop I have ever used.', TRUE, TRUE, 67),
(5, 6, 4, 'Excellent performance', 'Great laptop for creative work. Expensive but worth it for the performance and build quality.', TRUE, TRUE, 34),

-- Sony headphones
(9, 4, 5, 'Best noise cancellation', 'These headphones are amazing. Noise cancellation is the best I have experienced. Sound quality is superb.', TRUE, TRUE, 89),
(9, 7, 5, 'Perfect for travel', 'Use these daily for commuting. Battery lasts forever and the ANC blocks everything out.', TRUE, TRUE, 56),

-- Clean Code
(25, 5, 5, 'Must read for developers', 'This book changed how I write code. Every developer should read this at least once.', TRUE, TRUE, 234),
(25, 6, 4, 'Great principles, some dated examples', 'The principles are timeless even if some examples show their age. Still highly recommended.', TRUE, TRUE, 145);


-- ============================================================================
-- ORDER DATABASE SEED DATA
-- ============================================================================

USE order_db;

-- -----------------------------------------------------------------------------
-- Shipping Methods
-- -----------------------------------------------------------------------------
INSERT INTO shipping_methods (code, name, description, price, free_shipping_threshold, estimated_days_min, estimated_days_max, is_active, sort_order) VALUES
('STANDARD', 'Standard Delivery', 'Delivery within 5-7 business days', 99.00, 999.00, 5, 7, TRUE, 1),
('EXPRESS', 'Express Delivery', 'Delivery within 2-3 business days', 199.00, 1999.00, 2, 3, TRUE, 2),
('SAME_DAY', 'Same Day Delivery', 'Delivery by end of day (order before 12 PM)', 399.00, NULL, 0, 0, TRUE, 3),
('FREE', 'Free Standard Delivery', 'Free delivery for orders above threshold', 0.00, NULL, 5, 7, TRUE, 4);

-- -----------------------------------------------------------------------------
-- Coupons
-- -----------------------------------------------------------------------------
INSERT INTO coupons (code, name, description, discount_type, discount_value, max_discount_amount, min_order_amount, max_uses, max_uses_per_user, is_active, starts_at, expires_at) VALUES
('WELCOME10', 'Welcome Discount', '10% off for new customers', 'PERCENTAGE', 10.00, 1000.00, 500.00, 1000, 1, TRUE, '2024-01-01 00:00:00', '2025-12-31 23:59:59'),
('FLAT500', 'Flat ₹500 Off', 'Flat ₹500 off on orders above ₹2999', 'FIXED_AMOUNT', 500.00, NULL, 2999.00, 500, 2, TRUE, '2024-01-01 00:00:00', '2025-06-30 23:59:59'),
('FREESHIP', 'Free Shipping', 'Free shipping on all orders', 'FREE_SHIPPING', 0.00, NULL, 0.00, NULL, 5, TRUE, '2024-01-01 00:00:00', '2025-12-31 23:59:59'),
('SUMMER25', 'Summer Sale', '25% off summer collection', 'PERCENTAGE', 25.00, 2500.00, 1000.00, 200, 1, TRUE, '2024-04-01 00:00:00', '2024-06-30 23:59:59'),
('ELECTRONICS15', 'Electronics Discount', '15% off all electronics', 'PERCENTAGE', 15.00, 5000.00, 5000.00, 100, 1, TRUE, '2024-01-01 00:00:00', '2025-12-31 23:59:59');

-- -----------------------------------------------------------------------------
-- Sample Carts
-- -----------------------------------------------------------------------------
INSERT INTO carts (id, user_id, status, subtotal, total, created_at) VALUES
(1, 3, 'ACTIVE', 159898.00, 159898.00, NOW()),
(2, 4, 'ACTIVE', 29990.00, 29990.00, NOW()),
(3, 5, 'ABANDONED', 13995.00, 13995.00, DATE_SUB(NOW(), INTERVAL 7 DAY));

INSERT INTO cart_items (cart_id, product_id, variant_id, product_name, sku, quantity, unit_price, total_price) VALUES
(1, 1, 1, 'iPhone 15 Pro 128GB Natural Titanium', 'PHONE-001-128-NAT', 1, 134900.00, 134900.00),
(1, 8, NULL, 'AirPods Pro 2', 'AUDIO-001', 1, 24900.00, 24900.00),
(2, 9, NULL, 'Sony WH-1000XM5', 'AUDIO-002', 1, 29990.00, 29990.00),
(3, 19, 10, 'Nike Air Max 270 Size 9 Black', 'FOOT-001-9-BLK', 1, 13995.00, 13995.00);

-- -----------------------------------------------------------------------------
-- Sample Orders
-- -----------------------------------------------------------------------------
INSERT INTO orders (id, order_number, user_id, status, payment_status, fulfillment_status, subtotal, shipping_total, tax_total, total, payment_method, shipping_method, shipping_address, billing_address, created_at) VALUES
(1, 'ORD-2024-000001', 3, 'DELIVERED', 'PAID', 'FULFILLED', 134900.00, 0.00, 0.00, 134900.00, 'CREDIT_CARD', 'EXPRESS',
 '{"name": "John Doe", "phone": "+91-9876543210", "address_line1": "123 Main Street", "address_line2": "Apt 4B", "city": "Mumbai", "state": "Maharashtra", "postal_code": "400001", "country": "India"}',
 '{"name": "John Doe", "phone": "+91-9876543210", "address_line1": "123 Main Street", "address_line2": "Apt 4B", "city": "Mumbai", "state": "Maharashtra", "postal_code": "400001", "country": "India"}',
 DATE_SUB(NOW(), INTERVAL 30 DAY)),

(2, 'ORD-2024-000002', 4, 'DELIVERED', 'PAID', 'FULFILLED', 29990.00, 99.00, 0.00, 30089.00, 'UPI', 'STANDARD',
 '{"name": "Jane Smith", "phone": "+91-9876543211", "address_line1": "789 Park Avenue", "address_line2": "Building C", "city": "Bangalore", "state": "Karnataka", "postal_code": "560001", "country": "India"}',
 NULL,
 DATE_SUB(NOW(), INTERVAL 20 DAY)),

(3, 'ORD-2024-000003', 5, 'SHIPPED', 'PAID', 'FULFILLED', 249900.00, 0.00, 0.00, 249900.00, 'CREDIT_CARD', 'EXPRESS',
 '{"name": "Mike Wilson", "phone": "+91-9876543212", "address_line1": "321 Lake View Road", "city": "Chennai", "state": "Tamil Nadu", "postal_code": "600001", "country": "India"}',
 NULL,
 DATE_SUB(NOW(), INTERVAL 5 DAY)),

(4, 'ORD-2024-000004', 6, 'PROCESSING', 'PAID', 'UNFULFILLED', 54990.00, 199.00, 0.00, 55189.00, 'DEBIT_CARD', 'EXPRESS',
 '{"name": "Sarah Jones", "phone": "+91-9876543213", "address_line1": "567 Hill Station Road", "address_line2": "Villa 12", "city": "Pune", "state": "Maharashtra", "postal_code": "411001", "country": "India"}',
 NULL,
 DATE_SUB(NOW(), INTERVAL 2 DAY)),

(5, 'ORD-2024-000005', 3, 'PENDING', 'PENDING', 'UNFULFILLED', 1795.00, 99.00, 0.00, 1894.00, 'COD', 'STANDARD',
 '{"name": "John Doe", "phone": "+91-9876543210", "address_line1": "456 Office Complex", "address_line2": "Floor 5", "city": "Mumbai", "state": "Maharashtra", "postal_code": "400051", "country": "India"}',
 NULL,
 NOW());

-- -----------------------------------------------------------------------------
-- Order Items
-- -----------------------------------------------------------------------------
INSERT INTO order_items (order_id, product_id, variant_id, product_name, variant_name, sku, quantity, unit_price, total_price, fulfilled_quantity) VALUES
(1, 1, 1, 'iPhone 15 Pro', '128GB Natural Titanium', 'PHONE-001-128-NAT', 1, 134900.00, 134900.00, 1),
(2, 9, NULL, 'Sony WH-1000XM5', NULL, 'AUDIO-002', 1, 29990.00, 29990.00, 1),
(3, 5, NULL, 'MacBook Pro 16"', NULL, 'LAPTOP-001', 1, 249900.00, 249900.00, 1),
(4, 15, NULL, 'PlayStation 5', NULL, 'GAME-001', 1, 54990.00, 54990.00, 0),
(5, 16, 5, 'Nike Dri-FIT T-Shirt', 'Medium Black', 'CLOTH-M-001-M-BLK', 1, 1795.00, 1795.00, 0);

-- -----------------------------------------------------------------------------
-- Order Status History
-- -----------------------------------------------------------------------------
INSERT INTO order_status_history (order_id, previous_status, new_status, notes, created_at) VALUES
(1, NULL, 'PENDING', 'Order placed', DATE_SUB(NOW(), INTERVAL 30 DAY)),
(1, 'PENDING', 'CONFIRMED', 'Payment confirmed', DATE_SUB(NOW(), INTERVAL 30 DAY)),
(1, 'CONFIRMED', 'PROCESSING', 'Order processing started', DATE_SUB(NOW(), INTERVAL 29 DAY)),
(1, 'PROCESSING', 'SHIPPED', 'Order shipped via Express Delivery', DATE_SUB(NOW(), INTERVAL 28 DAY)),
(1, 'SHIPPED', 'DELIVERED', 'Order delivered successfully', DATE_SUB(NOW(), INTERVAL 26 DAY)),

(2, NULL, 'PENDING', 'Order placed', DATE_SUB(NOW(), INTERVAL 20 DAY)),
(2, 'PENDING', 'CONFIRMED', 'Payment confirmed', DATE_SUB(NOW(), INTERVAL 20 DAY)),
(2, 'CONFIRMED', 'SHIPPED', 'Order shipped', DATE_SUB(NOW(), INTERVAL 18 DAY)),
(2, 'SHIPPED', 'DELIVERED', 'Order delivered', DATE_SUB(NOW(), INTERVAL 14 DAY)),

(3, NULL, 'PENDING', 'Order placed', DATE_SUB(NOW(), INTERVAL 5 DAY)),
(3, 'PENDING', 'CONFIRMED', 'Payment confirmed', DATE_SUB(NOW(), INTERVAL 5 DAY)),
(3, 'CONFIRMED', 'SHIPPED', 'Order shipped', DATE_SUB(NOW(), INTERVAL 3 DAY));

-- -----------------------------------------------------------------------------
-- Payments
-- -----------------------------------------------------------------------------
INSERT INTO payments (order_id, payment_method, payment_gateway, transaction_id, amount, currency, status, paid_at) VALUES
(1, 'CREDIT_CARD', 'RAZORPAY', 'pay_ABC123456789', 134900.00, 'INR', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 30 DAY)),
(2, 'UPI', 'RAZORPAY', 'pay_DEF123456789', 30089.00, 'INR', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 20 DAY)),
(3, 'CREDIT_CARD', 'STRIPE', 'pi_GHI123456789', 249900.00, 'INR', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 5 DAY)),
(4, 'DEBIT_CARD', 'RAZORPAY', 'pay_JKL123456789', 55189.00, 'INR', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(5, 'COD', NULL, NULL, 1894.00, 'INR', 'PENDING', NULL);


-- ============================================================================
-- END OF SEED DATA
-- ============================================================================

SELECT 'Seed data loaded successfully!' AS status;
