-- ============================================================================
-- Project : Olist E-Commerce SQL Analytics
-- File    : 03_Data_Validation.sql
-- Purpose : Validate data completeness, consistency, and business rules
--           after data import.
-- ============================================================================

USE olist;

-- ========================================================================================
-- 1. Row Count Validation
-- ========================================================================================

-- Verify the number of records imported into each table.

SELECT 'customers' AS table_name, COUNT(*) AS total_rows
FROM customers

UNION ALL

SELECT 'sellers', COUNT(*)
FROM sellers

UNION ALL

SELECT 'product_category_translation', COUNT(*)
FROM product_category_translation

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items

UNION ALL

SELECT 'order_payments', COUNT(*)
FROM order_payments;


-- ========================================================================================
-- 2. NULL Value Checks
-- ========================================================================================

-- Primary key columns are already defined as NOT NULL through PRIMARY KEY
-- constraints, so they do not need to be checked again.


-- Orders

SELECT
    COUNT(*) AS total_orders,
    SUM(order_purchase_timestamp IS NULL) AS null_purchase_date,
    SUM(order_approved_at IS NULL) AS null_approval_date,
    SUM(order_delivered_carrier_date IS NULL) AS null_carrier_delivery_date,
    SUM(order_delivered_customer_date IS NULL) AS null_customer_delivery_date,
    SUM(order_estimated_delivery_date IS NULL) AS null_estimated_delivery_date
FROM orders;

-- Investigate NULL values by order status to distinguish
-- expected missing dates from potential data-quality issues.

SELECT
    order_status,
    COUNT(*) AS total_orders,
    SUM(order_approved_at IS NULL) AS null_approval,
    SUM(order_delivered_carrier_date IS NULL) AS null_carrier_delivery,
    SUM(order_delivered_customer_date IS NULL) AS null_customer_delivery
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- Most NULL delivery dates are associated with non-delivered orders,
-- so they are expected. No data correction is required.

-- Products

SELECT
    COUNT(*) AS total_products,
    SUM(product_category_name IS NULL) AS null_category,
    SUM(product_weight_g IS NULL) AS null_weight,
    SUM(product_length_cm IS NULL) AS null_length,
    SUM(product_height_cm IS NULL) AS null_height,
    SUM(product_width_cm IS NULL) AS null_width
FROM products;

-- 610 products have no category. These records are retained as source data.

-- Order Items

SELECT
    COUNT(*) AS total_order_items,
    SUM(product_id IS NULL) AS null_product_id,
    SUM(seller_id IS NULL) AS null_seller_id,
    SUM(price IS NULL) AS null_price,
    SUM(freight_value IS NULL) AS null_freight_value
FROM order_items;

-- No NULL values

-- Order Payments

SELECT
    COUNT(*) AS total_payments,
    SUM(payment_type IS NULL) AS null_payment_type,
    SUM(payment_installments IS NULL) AS null_installments,
    SUM(payment_value IS NULL) AS null_payment_value
FROM order_payments;

-- No NULL values

-- ========================================================================================
-- 3. Business Rule Validation
-- ========================================================================================

-- Check for negative product measurements.

SELECT *
FROM products
WHERE product_weight_g < 0
   OR product_length_cm < 0
   OR product_height_cm < 0
   OR product_width_cm < 0;

-- No negative product measurements were found.


-- Check for negative order item values.

SELECT *
FROM order_items
WHERE price < 0
   OR freight_value < 0;
   
-- No negative order item values were found.   


-- Check for invalid payment values.

SELECT *
FROM order_payments
WHERE payment_value < 0;

-- No invalid payment values found


-- Check for invalid payment installments.

SELECT *
FROM order_payments
WHERE payment_installments < 0;

-- No invalid payment instalments found


-- Check for invalid payment sequence numbers.

SELECT *
FROM order_payments
WHERE payment_sequential <= 0;

-- No invalid payment sequence numbers found


-- ========================================================================================
-- 4. Order Date Validation
-- ========================================================================================

-- Check whether an order was approved before it was purchased.

SELECT
    order_id,
    order_purchase_timestamp,
    order_approved_at
FROM orders
WHERE order_approved_at < order_purchase_timestamp;

-- No orders were approved before purchase, confirming consistent order chronology.


-- Check whether an order was delivered before it was purchased.

SELECT
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date
FROM orders
WHERE order_delivered_customer_date < order_purchase_timestamp;

-- No orders were delivered before purchase, confirming consistent order chronology.


-- Check whether an order was delivered after its estimated delivery date.

SELECT
    order_id,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM orders
WHERE order_delivered_customer_date >
      order_estimated_delivery_date;
      
-- Some orders were delivered after the estimated date, indicating late deliveries.


-- ========================================================================================
-- 5. Product Category Translation Validation
-- ========================================================================================

-- No foreign key is enforced between products and product_category_translation
-- because some product categories have no translation.

-- Identify product categories that do not have an English translation.

SELECT DISTINCT
    p.product_category_name
FROM products p
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL
ORDER BY p.product_category_name;

-- Only two product categories have no English translation.

-- ========================================================================================
-- 6. Categorical Value Validation
-- ========================================================================================

-- Review available order statuses.

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- Review available payment types.

SELECT
    payment_type,
    COUNT(*) AS total_payments
FROM order_payments
GROUP BY payment_type
ORDER BY total_payments DESC;

-- 3 orders have an undefined payment type ('not_defined').


-- Review available customer states.

SELECT
    customer_state,
    COUNT(*) AS total_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC;


-- Review available seller states.

SELECT
    seller_state,
    COUNT(*) AS total_sellers
FROM sellers
GROUP BY seller_state
ORDER BY total_sellers DESC;


-- ========================================================================================
-- 7. Order Item Consistency Validation
-- ========================================================================================

-- Identify orders containing multiple items.

SELECT
    order_id,
    COUNT(*) AS item_count
FROM order_items
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY item_count DESC;


-- Find the maximum number of items in a single order.

SELECT
    MAX(item_count) AS maximum_items_per_order
FROM
(
    SELECT
        order_id,
        COUNT(*) AS item_count
    FROM order_items
    GROUP BY order_id
) AS order_item_counts;

-- The maximum number of items in a single order is 21.


-- ========================================================================================
-- 8. Customer Identity Validation
-- ========================================================================================

-- A customer_id represents a customer record associated with an order,
-- while customer_unique_id identifies the actual customer.

-- Identify customers associated with multiple customer_id values.

SELECT
    customer_unique_id,
    COUNT(DISTINCT customer_id) AS customer_id_count
FROM customers
GROUP BY customer_unique_id
HAVING COUNT(DISTINCT customer_id) > 1
ORDER BY customer_id_count DESC;

-- Multiple customer_id values are expected because each represents an order-level customer record.

-- Compare customer_id count with the number of orders for these customers.

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT c.customer_id) AS customer_id_count,
    COUNT(DISTINCT o.order_id) AS order_count
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(DISTINCT c.customer_id) > 1
ORDER BY customer_id_count DESC, order_count DESC;

-- Matching counts confirm that each customer_id corresponds to one order.

-- ========================================================================================
-- 9. Referential Integrity Verification
-- ========================================================================================

-- Primary and foreign key constraints already enforce referential integrity.
-- These queries provide an additional verification of the imported data.

-- Orders without a matching customer.

SELECT COUNT(*) AS invalid_customer_references
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- No orders have invalid customer references.


-- Order items without a matching order.

SELECT COUNT(*) AS invalid_order_references
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- No order items have invalid order references.


-- Order items without a matching product.

SELECT COUNT(*) AS invalid_product_references
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- No order items have invalid product references.


-- Order items without a matching seller.

SELECT COUNT(*) AS invalid_seller_references
FROM order_items oi
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- No order items have invalid seller references.


-- Payments without a matching order.

SELECT COUNT(*) AS invalid_payment_references
FROM order_payments op
LEFT JOIN orders o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL;

-- No payments have invalid order references.


-- ========================================================================================
-- 10. Final Row Count Summary
-- ========================================================================================

SELECT
    (SELECT COUNT(*) FROM customers) AS customers,
    (SELECT COUNT(*) FROM sellers) AS sellers,
    (SELECT COUNT(*) FROM products) AS products,
    (SELECT COUNT(*) FROM orders) AS orders,
    (SELECT COUNT(*) FROM order_items) AS order_items,
    (SELECT COUNT(*) FROM order_payments) AS order_payments,
    (SELECT COUNT(*) FROM product_category_translation)
        AS category_translations;


-- ========================================================================================
-- End of Data Validation
-- ========================================================================================