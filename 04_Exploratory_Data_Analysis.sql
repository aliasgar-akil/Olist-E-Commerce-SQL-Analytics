-- ============================================================================
-- Project : Olist E-Commerce SQL Analytics
-- File    : 04_Exploratory_Data_Analysis.sql
-- Purpose : Explore customer, order, product, seller, payment, and
--           delivery patterns in the Olist dataset.
-- ============================================================================

USE olist;

-- ========================================================================================
-- 1. Order & Sales Overview
-- ========================================================================================

-- Total orders, order items, sales, and freight.

SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS total_order_items,
    ROUND(SUM(price), 2) AS total_sales,
    ROUND(SUM(freight_value), 2) AS total_freight
FROM order_items;


-- Average order value.

SELECT
    ROUND(SUM(price) / COUNT(DISTINCT order_id), 2) AS average_order_value
FROM order_items;


-- Orders and sales by year.

SELECT
    YEAR(o.order_purchase_timestamp) AS order_year,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_sales
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY YEAR(o.order_purchase_timestamp)
ORDER BY order_year;


-- Monthly orders and sales.

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_sales
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY order_month;


-- ========================================================================================
-- 2. Customer Analysis
-- ========================================================================================

-- Customers by state.

SELECT
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC;


-- Orders by customer state.

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;


-- One-time vs repeat customers.

WITH customer_orders AS
(
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS total_customers
FROM customer_orders
GROUP BY customer_type;


-- Top customers by number of orders.

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC
LIMIT 10;


-- ========================================================================================
-- 3. Product & Category Analysis
-- ========================================================================================

-- Top product categories by items sold.

SELECT
    COALESCE(
        t.product_category_name_english,
        p.product_category_name
    ) AS product_category,
    COUNT(*) AS items_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY 
	COALESCE(
        t.product_category_name_english,
        p.product_category_name
    )
ORDER BY items_sold DESC
LIMIT 10;


-- Top product categories by sales.

SELECT
    COALESCE(
        t.product_category_name_english,
        p.product_category_name
    ) AS product_category,
    ROUND(SUM(oi.price), 2) AS total_sales
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY 
	COALESCE(
        t.product_category_name_english,
        p.product_category_name
    )
ORDER BY total_sales DESC
LIMIT 10;


-- Top products by sales.

SELECT
    product_id,
    ROUND(SUM(price), 2) AS total_sales
FROM order_items
GROUP BY product_id
ORDER BY total_sales DESC
LIMIT 10;


-- ========================================================================================
-- 4. Seller Analysis
-- ========================================================================================

-- Sellers by state.

SELECT
    seller_state,
    COUNT(DISTINCT seller_id) AS total_sellers
FROM sellers
GROUP BY seller_state
ORDER BY total_sellers DESC;


-- Top sellers by sales.

SELECT
    seller_id,
    ROUND(SUM(price), 2) AS total_sales
FROM order_items
GROUP BY seller_id
ORDER BY total_sales DESC
LIMIT 10;


-- Top sellers by number of orders.

SELECT
    seller_id,
    COUNT(DISTINCT order_id) AS total_orders
FROM order_items
GROUP BY seller_id
ORDER BY total_orders DESC
LIMIT 10;


-- ========================================================================================
-- 5. Payment Analysis
-- ========================================================================================

-- Payment type distribution.

SELECT
    payment_type,
    COUNT(*) AS payment_records,
    ROUND(SUM(payment_value), 2) AS total_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;


-- Average installments by payment type.

SELECT
    payment_type,
    ROUND(AVG(payment_installments), 2) AS avg_installments
FROM order_payments
GROUP BY payment_type
ORDER BY avg_installments DESC;


-- ========================================================================================
-- 6. Delivery Analysis
-- ========================================================================================

-- Average delivery time.

SELECT
    ROUND(
        AVG(
            TIMESTAMPDIFF(
                DAY,
                order_purchase_timestamp,
                order_delivered_customer_date
            )
        ),
        2
    ) AS avg_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;


-- Average delivery time by customer state.

SELECT
    c.customer_state,
    ROUND(
        AVG(
            TIMESTAMPDIFF(
                DAY,
                o.order_purchase_timestamp,
                o.order_delivered_customer_date
            )
        ),
        2
    ) AS avg_delivery_days
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days;


-- Late delivery rate.

SELECT
    ROUND(
        SUM(
            CASE
                WHEN order_delivered_customer_date >
                     order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ) * 100 / COUNT(*),
        2
    ) AS late_delivery_rate
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;

-- ========================================================================================
-- End of Exploratory Data Analysis
-- ========================================================================================