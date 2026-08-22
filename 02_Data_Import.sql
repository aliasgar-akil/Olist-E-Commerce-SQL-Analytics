-- ============================================================================
-- Project : Olist E-Commerce SQL Analytics
-- File    : 02_Data_Import.sql
-- Purpose : Import Olist CSV data into the MySQL database.
-- ============================================================================

USE olist;

-- ========================================================================================
-- Check and Enable LOCAL INFILE
-- ========================================================================================

-- Check whether LOCAL INFILE is enabled.
-- It is required to load CSV files stored on the local machine using
-- LOAD DATA LOCAL INFILE.
SHOW GLOBAL VARIABLES LIKE 'local_infile';

-- Enable LOCAL INFILE if it is disabled.
-- This allows MySQL to read the Olist CSV files from the local machine.
SET GLOBAL local_infile = 1;

-- Verify that LOCAL INFILE is enabled.
SHOW GLOBAL VARIABLES LIKE 'local_infile';

-- ========================================================================================
-- Import Product Category Translation
-- ========================================================================================

LOAD DATA LOCAL INFILE 'E:/Olist/product_category_name_translation.csv'
INTO TABLE product_category_translation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ========================================================================================
-- Import Customers
-- ========================================================================================

LOAD DATA LOCAL INFILE 'E:/Olist/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ========================================================================================
-- Import Sellers
-- ========================================================================================

LOAD DATA LOCAL INFILE 'E:/Olist/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ========================================================================================
-- Import Products
-- ========================================================================================

-- Products require additional handling because the source CSV contains blank
-- values in some numeric columns and blank product categories.

-- Temporary variables (@...) are used to capture the CSV values before insertion.
-- NULLIF() converts empty strings ('') to NULL so that blank values are stored
-- correctly and do not cause integer conversion or foreign-key errors.

LOAD DATA LOCAL INFILE 'E:/Olist/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    product_id,
    @product_category_name,
    @product_name_lenght,
    @product_description_lenght,
    @product_photos_qty,
    @product_weight_g,
    @product_length_cm,
    @product_height_cm,
    @product_width_cm
)
SET
    product_category_name = NULLIF(@product_category_name, ''),
    product_name_lenght = NULLIF(@product_name_lenght, ''),
    product_description_lenght = NULLIF(@product_description_lenght, ''),
    product_photos_qty = NULLIF(@product_photos_qty, ''),
    product_weight_g = NULLIF(@product_weight_g, ''),
    product_length_cm = NULLIF(@product_length_cm, ''),
    product_height_cm = NULLIF(@product_height_cm, ''),
    product_width_cm = NULLIF(@product_width_cm, '');

-- ========================================================================================
-- Import Orders
-- ========================================================================================

LOAD DATA LOCAL INFILE 'E:/Olist/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    customer_id,
    order_status,
    @order_purchase_timestamp,
    @order_approved_at,
    @order_delivered_carrier_date,
    @order_delivered_customer_date,
    @order_estimated_delivery_date
)
SET
    order_purchase_timestamp = NULLIF(@order_purchase_timestamp, ''),
    order_approved_at = NULLIF(@order_approved_at, ''),
    order_delivered_carrier_date = NULLIF(@order_delivered_carrier_date, ''),
    order_delivered_customer_date = NULLIF(@order_delivered_customer_date, ''),
    order_estimated_delivery_date = NULLIF(@order_estimated_delivery_date, '');

-- ========================================================================================
-- Import Order Items
-- ========================================================================================

LOAD DATA LOCAL INFILE 'E:/Olist/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ========================================================================================
-- Import Order Payments
-- ========================================================================================

LOAD DATA LOCAL INFILE 'E:/Olist/olist_order_payments_dataset.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ========================================================================================
-- End of Data Import
-- ========================================================================================

