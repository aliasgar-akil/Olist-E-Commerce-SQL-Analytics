-- ============================================================================
-- Project : Olist E-Commerce SQL Analytics
-- File    : 01_Database_Setup.sql
-- Purpose : Create the database schema, relationships, and indexes.
-- ============================================================================

-- ========================================================================================
-- Create Database
-- ========================================================================================

DROP DATABASE IF EXISTS olist;

CREATE DATABASE olist;

USE olist;

-- ========================================================================================
-- Customers
-- ========================================================================================

CREATE TABLE customers (

    customer_id CHAR(32) PRIMARY KEY,

    customer_unique_id CHAR(32) NOT NULL,

    customer_zip_code_prefix INT,

    customer_city VARCHAR(100),

    customer_state CHAR(2)

);

-- ========================================================================================
-- Sellers
-- ========================================================================================

CREATE TABLE sellers (

    seller_id CHAR(32) PRIMARY KEY,

    seller_zip_code_prefix INT,

    seller_city VARCHAR(100),

    seller_state CHAR(2)

);

-- ========================================================================================
-- Product Category Translation
-- ========================================================================================

CREATE TABLE product_category_translation (

    product_category_name VARCHAR(100) PRIMARY KEY,

    product_category_name_english VARCHAR(100)

);

-- ========================================================================================
-- Products
-- ========================================================================================

CREATE TABLE products (

    product_id CHAR(32) PRIMARY KEY,

    product_category_name VARCHAR(100),

    product_name_lenght INT,

    product_description_lenght INT,

    product_photos_qty INT,

    product_weight_g INT,

    product_length_cm INT,

    product_height_cm INT,

    product_width_cm INT
    
);

-- Product category translation is kept as a lookup table rather than enforcing
-- a foreign key because the translation dataset does not contain every category
-- present in the products dataset. 

-- ========================================================================================
-- Orders
-- ========================================================================================

CREATE TABLE orders (

    order_id CHAR(32) PRIMARY KEY,

    customer_id CHAR(32) NOT NULL,

    order_status VARCHAR(20),

    order_purchase_timestamp DATETIME,

    order_approved_at DATETIME,

    order_delivered_carrier_date DATETIME,

    order_delivered_customer_date DATETIME,

    order_estimated_delivery_date DATETIME,

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)

);

-- ========================================================================================
-- Order Items
-- ========================================================================================

CREATE TABLE order_items (

    order_id CHAR(32),

    order_item_id INT NOT NULL,

    product_id CHAR(32),

    seller_id CHAR(32),

    shipping_limit_date DATETIME,

    price DECIMAL(10,2) NOT NULL,

    freight_value DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (order_id, order_item_id),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    FOREIGN KEY (product_id)
        REFERENCES products(product_id),

    FOREIGN KEY (seller_id)
        REFERENCES sellers(seller_id)

);

-- ========================================================================================
-- Order Payments
-- ========================================================================================

CREATE TABLE order_payments (

    order_id CHAR(32),

    payment_sequential INT NOT NULL,

    payment_type VARCHAR(30),

    payment_installments INT,

    payment_value DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (order_id, payment_sequential),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)

);

-- ========================================================================================
-- Indexes
-- ========================================================================================

-- Customers
CREATE INDEX idx_customer_unique
ON customers(customer_unique_id);

CREATE INDEX idx_customer_city
ON customers(customer_city);

CREATE INDEX idx_customer_state
ON customers(customer_state);

-- Sellers
CREATE INDEX idx_seller_city
ON sellers(seller_city);

CREATE INDEX idx_seller_state
ON sellers(seller_state);

-- Products
CREATE INDEX idx_product_category
ON products(product_category_name);

-- Orders
CREATE INDEX idx_orders_customer
ON orders(customer_id);

CREATE INDEX idx_orders_status
ON orders(order_status);

CREATE INDEX idx_orders_purchase_date
ON orders(order_purchase_timestamp);

-- Order Items
CREATE INDEX idx_orderitems_product
ON order_items(product_id);

CREATE INDEX idx_orderitems_seller
ON order_items(seller_id);

-- Order Payments
CREATE INDEX idx_payment_type
ON order_payments(payment_type);

CREATE INDEX idx_payment_installments
ON order_payments(payment_installments);

-- ========================================================================================
-- Verify Database Structure
-- ========================================================================================

SHOW TABLES;

DESCRIBE customers;
DESCRIBE orders;
DESCRIBE order_items;
DESCRIBE order_payments;
DESCRIBE sellers;
DESCRIBE products;
DESCRIBE product_category_translation;