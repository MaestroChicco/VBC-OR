-- ====================================
-- VBC (Venture Business Collect) Database Schema
-- WhatsApp Retail Shop with Ghala Integration
-- ====================================

-- Drop existing tables if they exist (for fresh installation)
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS cart_items;
DROP TABLE IF EXISTS product_images;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customer_interactions;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS payment_transactions;
DROP TABLE IF EXISTS bot_sessions;
DROP TABLE IF EXISTS admin_users;
DROP TABLE IF EXISTS settings;

-- ====================================
-- 1. CATEGORIES TABLE
-- ====================================
CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50), -- Emoji or icon identifier
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ====================================
-- 2. PRODUCTS TABLE
-- ====================================
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    original_price DECIMAL(10,2), -- For discounts
    sku VARCHAR(100) UNIQUE,
    stock_quantity INT DEFAULT 0,
    min_stock_level INT DEFAULT 5,
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    weight DECIMAL(8,2), -- In KG for shipping
    dimensions VARCHAR(100), -- LxWxH in cm
    tags TEXT, -- Comma-separated tags for search
    meta_keywords TEXT,
    views_count INT DEFAULT 0,
    sales_count INT DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 0.00,
    rating_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    INDEX idx_category (category_id),
    INDEX idx_active (is_active),
    INDEX idx_featured (is_featured),
    INDEX idx_price (price),
    FULLTEXT idx_search (name, description, tags)
);

-- ====================================
-- 3. PRODUCT IMAGES TABLE
-- ====================================
CREATE TABLE product_images (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    alt_text VARCHAR(255),
    is_primary BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_product (product_id)
);

-- ====================================
-- 4. CUSTOMERS TABLE
-- ====================================
CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    whatsapp_number VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(255),
    email VARCHAR(255),
    date_of_birth DATE,
    gender ENUM('male', 'female', 'other'),
    location VARCHAR(255),
    preferred_language VARCHAR(10) DEFAULT 'en',
    subscription_plan ENUM('free', 'premium', 'business') DEFAULT 'free',
    subscription_expires_at TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_blocked BOOLEAN DEFAULT FALSE,
    total_orders INT DEFAULT 0,
    total_spent DECIMAL(12,2) DEFAULT 0.00,
    loyalty_points INT DEFAULT 0,
    referral_code VARCHAR(20) UNIQUE,
    referred_by VARCHAR(20),
    last_interaction TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_whatsapp (whatsapp_number),
    INDEX idx_subscription (subscription_plan),
    INDEX idx_active (is_active)
);

-- ====================================
-- 5. BOT SESSIONS TABLE
-- ====================================
CREATE TABLE bot_sessions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    session_id VARCHAR(100) NOT NULL UNIQUE,
    current_state VARCHAR(50) DEFAULT 'welcome', -- welcome, browsing, cart, checkout, etc.
    context_data JSON, -- Store current conversation context
    is_active BOOLEAN DEFAULT TRUE,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    ended_at TIMESTAMP NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    INDEX idx_customer (customer_id),
    INDEX idx_session (session_id),
    INDEX idx_active (is_active)
);

-- ====================================
-- 6. CUSTOMER INTERACTIONS TABLE
-- ====================================
CREATE TABLE customer_interactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    session_id VARCHAR(100),
    interaction_type ENUM('message', 'product_view', 'add_to_cart', 'remove_from_cart', 'order_placed', 'payment', 'other') NOT NULL,
    message_direction ENUM('incoming', 'outgoing') DEFAULT 'incoming',
    message_content TEXT,
    product_id INT NULL,
    metadata JSON, -- Additional data like button clicks, etc.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL,
    INDEX idx_customer (customer_id),
    INDEX idx_session (session_id),
    INDEX idx_type (interaction_type),
    INDEX idx_created (created_at)
);

-- ====================================
-- 7. CART ITEMS TABLE
-- ====================================
CREATE TABLE cart_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY unique_customer_product (customer_id, product_id),
    INDEX idx_customer (customer_id)
);

-- ====================================
-- 8. ORDERS TABLE
-- ====================================
CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    status ENUM('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded') DEFAULT 'pending',
    payment_status ENUM('pending', 'paid', 'failed', 'refunded') DEFAULT 'pending',
    payment_method VARCHAR(50), -- ghala, mobile_money, bank_transfer, etc.
    subtotal DECIMAL(12,2) NOT NULL,
    shipping_cost DECIMAL(10,2) DEFAULT 0.00,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    total_amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'TZS',
    
    -- Shipping Information
    shipping_name VARCHAR(255),
    shipping_phone VARCHAR(20),
    shipping_address TEXT,
    shipping_city VARCHAR(100),
    shipping_region VARCHAR(100),
    shipping_postal_code VARCHAR(20),
    
    -- Tracking
    tracking_number VARCHAR(100),
    estimated_delivery DATE,
    delivered_at TIMESTAMP NULL,
    
    -- Notes
    customer_notes TEXT,
    admin_notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    INDEX idx_customer (customer_id),
    INDEX idx_status (status),
    INDEX idx_payment_status (payment_status),
    INDEX idx_order_number (order_number),
    INDEX idx_created (created_at)
);

-- ====================================
-- 9. ORDER ITEMS TABLE
-- ====================================
CREATE TABLE order_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL, -- Store name at time of order
    product_sku VARCHAR(100),
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT,
    INDEX idx_order (order_id),
    INDEX idx_product (product_id)
);

-- ====================================
-- 10. PAYMENT TRANSACTIONS TABLE
-- ====================================
CREATE TABLE payment_transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    customer_id INT NOT NULL,
    transaction_id VARCHAR(100) NOT NULL UNIQUE, -- From Ghala or payment provider
    payment_method VARCHAR(50) NOT NULL,
    payment_provider VARCHAR(50) NOT NULL, -- ghala, mpesa, tigopesa, etc.
    amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'TZS',
    status ENUM('pending', 'success', 'failed', 'cancelled', 'refunded') DEFAULT 'pending',
    provider_response JSON, -- Store full response from payment provider
    reference_number VARCHAR(100),
    processed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    INDEX idx_order (order_id),
    INDEX idx_customer (customer_id),
    INDEX idx_transaction (transaction_id),
    INDEX idx_status (status)
);

-- ====================================
-- 11. ADMIN USERS TABLE
-- ====================================
CREATE TABLE admin_users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    role ENUM('super_admin', 'admin', 'manager', 'support') DEFAULT 'support',
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_role (role)
);

-- ====================================
-- 12. SETTINGS TABLE
-- ====================================
CREATE TABLE settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT,
    setting_type ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string',
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE, -- Can be accessed by frontend
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_key (setting_key),
    INDEX idx_public (is_public)
);

-- ====================================
-- INSERT INITIAL DATA
-- ====================================

-- Insert default categories
INSERT INTO categories (name, description, icon, sort_order) VALUES
('Electronics', 'Smartphones, laptops, and gadgets', '📱', 1),
('Fashion', 'Clothing, shoes, and accessories', '👕', 2),
('Home & Living', 'Furniture, decor, and household items', '🏠', 3),
('Beauty', 'Cosmetics, skincare, and personal care', '💄', 4),
('Sports', 'Athletic wear and sports equipment', '🏃', 5),
('Books', 'Educational and entertainment reading', '📚', 6);

-- Insert sample products
INSERT INTO products (category_id, name, description, price, original_price, sku, stock_quantity, is_featured) VALUES
(1, 'iPhone 15 Pro Max', 'Latest Apple smartphone with advanced camera system', 2500000.00, 2800000.00, 'IP15PM-256', 10, TRUE),
(1, 'Samsung Galaxy S24', 'Premium Android smartphone with AI features', 1800000.00, 2000000.00, 'SGS24-128', 15, TRUE),
(2, 'Nike Air Max Sneakers', 'Comfortable running shoes for daily wear', 180000.00, 220000.00, 'NAM-001', 25, FALSE),
(3, 'Modern Coffee Table', 'Stylish wooden coffee table for living room', 450000.00, NULL, 'MCT-WD01', 5, FALSE),
(4, 'Skincare Bundle Set', 'Complete skincare routine with cleanser, toner, and moisturizer', 85000.00, 120000.00, 'SKB-001', 30, TRUE);

-- Insert default admin user (password: admin123 - should be changed!)
INSERT INTO admin_users (username, email, password_hash, full_name, role) VALUES
('admin', 'admin@vbc.co.tz', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'VBC Administrator', 'super_admin');

-- Insert default settings
INSERT INTO settings (setting_key, setting_value, setting_type, description, is_public) VALUES
('site_name', 'Venture Business Collect', 'string', 'Website name', TRUE),
('whatsapp_number', '+255000000000', 'string', 'Main WhatsApp business number', TRUE),
('currency_symbol', 'TZS', 'string', 'Default currency symbol', TRUE),
('tax_rate', '18', 'number', 'VAT rate percentage', FALSE),
('shipping_cost', '5000', 'number', 'Default shipping cost in TZS', TRUE),
('free_shipping_threshold', '100000', 'number', 'Minimum order for free shipping', TRUE),
('business_hours', '{"start": "08:00", "end": "18:00", "days": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]}', 'json', 'Business operating hours', TRUE),
('welcome_message', 'Welcome to VBC! 🛍️ How can we help you today?', 'string', 'Bot welcome message', FALSE),
('ghala_api_key', '', 'string', 'Ghala payment gateway API key', FALSE),
('auto_confirm_orders', 'false', 'boolean', 'Automatically confirm orders after payment', FALSE);

-- ====================================
-- CREATE INDEXES FOR PERFORMANCE
-- ====================================

-- Additional composite indexes for common queries
CREATE INDEX idx_products_category_active ON products(category_id, is_active);
CREATE INDEX idx_products_featured_active ON products(is_featured, is_active);
CREATE INDEX idx_orders_customer_status ON orders(customer_id, status);
CREATE INDEX idx_orders_date_status ON orders(created_at, status);
CREATE INDEX idx_interactions_customer_date ON customer_interactions(customer_id, created_at);

-- ====================================
-- CREATE VIEWS FOR COMMON QUERIES
-- ====================================

-- Active products with category info
CREATE VIEW active_products_view AS
SELECT 
    p.*,
    c.name as category_name,
    c.icon as category_icon,
    (SELECT image_url FROM product_images pi WHERE pi.product_id = p.id AND pi.is_primary = 1 LIMIT 1) as primary_image
FROM products p
JOIN categories c ON p.category_id = c.id
WHERE p.is_active = 1 AND c.is_active = 1;

-- Customer summary view
CREATE VIEW customer_summary_view AS
SELECT 
    c.*,
    COUNT(o.id) as total_orders,
    COALESCE(SUM(o.total_amount), 0) as total_spent,
    MAX(o.created_at) as last_order_date
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id AND o.status != 'cancelled'
GROUP BY c.id;

-- Order details view
CREATE VIEW order_details_view AS
SELECT 
    o.*,
    c.name as customer_name,
    c.whatsapp_number,
    COUNT(oi.id) as total_items,
    SUM(oi.quantity) as total_quantity
FROM orders o
JOIN customers c ON o.customer_id = c.id
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id;

-- ====================================
-- STORED PROCEDURES
-- ====================================

DELIMITER //

-- Procedure to add item to cart
CREATE PROCEDURE AddToCart(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;
    
    -- Get product price and stock
    SELECT price, stock_quantity INTO v_price, v_stock
    FROM products 
    WHERE id = p_product_id AND is_active = 1;
    
    -- Check if product exists and has stock
    IF v_price IS NOT NULL AND v_stock >= p_quantity THEN
        -- Insert or update cart item
        INSERT INTO cart_items (customer_id, product_id, quantity, unit_price)
        VALUES (p_customer_id, p_product_id, p_quantity, v_price)
        ON DUPLICATE KEY UPDATE 
            quantity = quantity + p_quantity,
            updated_at = CURRENT_TIMESTAMP;
        
        SELECT 'success' as status, 'Item added to cart' as message;
    ELSE
        SELECT 'error' as status, 'Product not available or insufficient stock' as message;
    END IF;
END//

-- Procedure to create order from cart
CREATE PROCEDURE CreateOrderFromCart(
    IN p_customer_id INT,
    IN p_shipping_name VARCHAR(255),
    IN p_shipping_phone VARCHAR(20),
    IN p_shipping_address TEXT
)
BEGIN
    DECLARE v_order_id INT;
    DECLARE v_order_number VARCHAR(50);
    DECLARE v_subtotal DECIMAL(12,2) DEFAULT 0;
    DECLARE v_shipping_cost DECIMAL(10,2);
    DECLARE v_total DECIMAL(12,2);
    
    -- Get shipping cost from settings
    SELECT CAST(setting_value AS DECIMAL(10,2)) INTO v_shipping_cost
    FROM settings WHERE setting_key = 'shipping_cost';
    
    -- Calculate cart total
    SELECT SUM(quantity * unit_price) INTO v_subtotal
    FROM cart_items WHERE customer_id = p_customer_id;
    
    -- Check if cart is not empty
    IF v_subtotal > 0 THEN
        -- Generate order number
        SET v_order_number = CONCAT('VBC', YEAR(NOW()), MONTH(NOW()), DAY(NOW()), '-', LPAD(p_customer_id, 4, '0'), '-', UNIX_TIMESTAMP());
        
        -- Calculate total
        SET v_total = v_subtotal + v_shipping_cost;
        
        -- Create order
        INSERT INTO orders (
            order_number, customer_id, subtotal, shipping_cost, total_amount,
            shipping_name, shipping_phone, shipping_address
        ) VALUES (
            v_order_number, p_customer_id, v_subtotal, v_shipping_cost, v_total,
            p_shipping_name, p_shipping_phone, p_shipping_address
        );
        
        SET v_order_id = LAST_INSERT_ID();
        
        -- Copy cart items to order items
        INSERT INTO order_items (order_id, product_id, product_name, product_sku, quantity, unit_price, total_price)
        SELECT 
            v_order_id,
            ci.product_id,
            p.name,
            p.sku,
            ci.quantity,
            ci.unit_price,
            ci.quantity * ci.unit_price
        FROM cart_items ci
        JOIN products p ON ci.product_id = p.id
        WHERE ci.customer_id = p_customer_id;
        
        -- Clear cart
        DELETE FROM cart_items WHERE customer_id = p_customer_id;
        
        -- Update customer stats
        UPDATE customers 
        SET total_orders = total_orders + 1,
            total_spent = total_spent + v_total
        WHERE id = p_customer_id;
        
        SELECT 'success' as status, v_order_number as order_number, v_order_id as order_id;
    ELSE
        SELECT 'error' as status, 'Cart is empty' as message;
    END IF;
END//

DELIMITER ;

-- ====================================
-- TRIGGERS
-- ====================================

DELIMITER //

-- Update product stock after order
CREATE TRIGGER update_stock_after_order
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE products 
    SET stock_quantity = stock_quantity - NEW.quantity,
        sales_count = sales_count + NEW.quantity
    WHERE id = NEW.product_id;
END//

-- Update customer last interaction
CREATE TRIGGER update_customer_interaction
AFTER INSERT ON customer_interactions
FOR EACH ROW
BEGIN
    UPDATE customers 
    SET last_interaction = NEW.created_at
    WHERE id = NEW.customer_id;
END//

-- Generate referral code for new customers
CREATE TRIGGER generate_referral_code
BEFORE INSERT ON customers
FOR EACH ROW
BEGIN
    IF NEW.referral_code IS NULL THEN
        SET NEW.referral_code = CONCAT('VBC', UPPER(SUBSTRING(MD5(CONCAT(NEW.whatsapp_number, UNIX_TIMESTAMP())), 1, 6)));
    END IF;
END//

DELIMITER ;

-- ====================================
-- SAMPLE QUERIES FOR TESTING
-- ====================================

/*
-- Get all active products with images
SELECT * FROM active_products_view ORDER BY created_at DESC;

-- Get customer cart
SELECT 
    ci.*,
    p.name as product_name,
    (ci.quantity * ci.unit_price) as line_total
FROM cart_items ci
JOIN products p ON ci.product_id = p.id
WHERE ci.customer_id = 1;

-- Get recent orders
SELECT * FROM order_details_view 
ORDER BY created_at DESC 
LIMIT 10;

-- Add item to cart
CALL AddToCart(1, 1, 2);

-- Create order from cart
CALL CreateOrderFromCart(1, 'John Doe', '+255123456789', '123 Main St, Dar es Salaam');
*/

-- ====================================
-- END OF SCHEMA
-- ====================================
