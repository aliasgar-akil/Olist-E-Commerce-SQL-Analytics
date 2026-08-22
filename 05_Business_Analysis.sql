-- ============================================================================
-- Project : Olist E-Commerce SQL Analytics
-- File    : 05_Business_Analysis.sql
-- Purpose : Answer real-world business questions and gain actionable insights
--           into sales, customers, products, sellers, and delivery performance.
-- ============================================================================

USE olist;

-- ========================================================================================
-- 1. Customer Lifetime Value
-- ========================================================================================

-- Why:
-- Identifies the customers generating the highest total spending,
-- helping prioritize high-value customers.

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(op.payment_value) AS lifetime_value,
    ROUND(
        SUM(op.payment_value) / COUNT(DISTINCT o.order_id),
        2
    ) AS avg_order_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_payments op
    ON o.order_id = op.order_id
GROUP BY c.customer_unique_id
ORDER BY lifetime_value DESC;

-- ========================================================================================
-- 2. Repeat Customer Revenue Contribution
-- ========================================================================================

-- Why:
-- Shows how much revenue comes from repeat customers,
-- indicating the importance of customer retention.

WITH customer_metrics AS
(
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(op.payment_value) AS total_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_payments op
        ON o.order_id = op.order_id
    GROUP BY c.customer_unique_id
)
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS total_customers,
    SUM(total_spending) AS total_spending,
    ROUND(
        100 * SUM(total_spending) /
        SUM(SUM(total_spending)) OVER(),
        2
    ) AS spending_share_pct
FROM customer_metrics
GROUP BY
    CASE
        WHEN order_count = 1 THEN 'One-time'
        ELSE 'Repeat'
    END;
    
-- Insight:
-- 93,098 customers (96.82%) are one-time customers, while 2,997 (3.18%)
-- are repeat customers. Repeat customers contribute 5.90% of total revenue.

-- ========================================================================================
-- 3. Monthly Revenue Growth
-- ========================================================================================

-- Why:
-- Identifies periods of revenue growth or decline,
-- helping understand sales trends over time.

WITH monthly_sales AS
(
    SELECT
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        ) AS order_month,
        SUM(op.payment_value) AS total_sales
    FROM orders o
    JOIN order_payments op
        ON o.order_id = op.order_id
    GROUP BY
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        )
),
sales_with_previous AS
(
    SELECT
        order_month,
        total_sales,
        LAG(total_sales) OVER (
            ORDER BY order_month
        ) AS previous_month_sales
    FROM monthly_sales
)
SELECT
    order_month,
    total_sales,
    previous_month_sales,
    ROUND(
        100 * (total_sales - previous_month_sales) / previous_month_sales,
        2
    ) AS growth_pct
FROM sales_with_previous
WHERE previous_month_sales IS NOT NULL;

-- ========================================================================================
-- 4. Revenue Contribution by Product Category
-- ========================================================================================

-- Why:
-- Measures how much each category contributes to total revenue,
-- helping identify the categories driving the business.

WITH category_sales AS
(
    SELECT
        COALESCE(
            t.product_category_name_english,
            p.product_category_name
        ) AS product_category,
        SUM(oi.price) AS total_sales
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_translation t
        ON p.product_category_name = t.product_category_name
	WHERE p.product_category_name IS NOT NULL
    GROUP BY
        COALESCE(
            t.product_category_name_english,
            p.product_category_name
        )
)
SELECT
    product_category,
    ROUND(total_sales, 2) AS total_sales,
    ROUND(
        100 * total_sales /
        SUM(total_sales) OVER (),
        2
    ) AS revenue_share_pct
FROM category_sales
ORDER BY total_sales DESC;

-- Insight:
-- Health & Beauty generated 9.38% of total sales (1.26M), followed by
-- Watches & Gifts at 8.98% (1.21M) and Bed Bath Table at 7.73% (1.04M).

-- ========================================================================================
-- 5. Top 3 Products Within Each Category
-- ========================================================================================

-- Why:
-- Identifies the strongest products within each category,
-- helping focus inventory and product-level decisions.

WITH product_sales AS
(
    SELECT
        COALESCE(
            t.product_category_name_english,
            p.product_category_name
        ) AS product_category,
        p.product_id,
        SUM(oi.price) AS total_sales
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
	LEFT JOIN product_category_translation t
		ON p.product_category_name = t.product_category_name
	WHERE p.product_category_name IS NOT NULL
    GROUP BY
        COALESCE(
            t.product_category_name_english,
            p.product_category_name
        ),
        p.product_id
),
ranked_products AS
(
    SELECT
        product_category,
        product_id,
        total_sales,
        DENSE_RANK() OVER (
            PARTITION BY product_category
            ORDER BY total_sales DESC
        ) AS product_rank
    FROM product_sales
)
SELECT
    product_category,
    product_id,
    total_sales
FROM ranked_products
WHERE product_rank <= 3;

-- ========================================================================================
-- 6. Seller Performance Ranking Within Each State
-- ========================================================================================

-- Why:
-- Compares sellers within the same state,
-- helping identify local high-performing sellers.

WITH seller_sales AS
(
    SELECT
        s.seller_state,
        s.seller_id,
        SUM(oi.price) AS total_sales
    FROM sellers s
    JOIN order_items oi
        ON s.seller_id = oi.seller_id
    GROUP BY
        s.seller_state,
        s.seller_id
)
SELECT
    seller_state,
    seller_id,
    total_sales,
    DENSE_RANK() OVER (
        PARTITION BY seller_state
        ORDER BY total_sales DESC
    ) AS state_rank
FROM seller_sales;


-- ========================================================================================
-- 7. High-Value Customers Above Average
-- ========================================================================================

-- Why:
-- Identifies customers spending more than the average customer,
-- helping target high-value customer segments.

WITH customer_spending AS
(
    SELECT
        c.customer_unique_id,
        SUM(op.payment_value) AS total_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_payments op
        ON o.order_id = op.order_id
    GROUP BY c.customer_unique_id
)
SELECT *
FROM customer_spending
WHERE total_spending >
(
    SELECT AVG(total_spending)
    FROM customer_spending
)
ORDER BY total_spending DESC;


-- ========================================================================================
-- 8. Customer Retention Rate by First Order Month
-- ========================================================================================

-- Why:
-- Measures the percentage of customers who return in a later month,
-- helping evaluate customer retention across different cohorts.

WITH customer_first_month AS
(
    SELECT
        c.customer_unique_id,
        DATE_FORMAT(MIN(o.order_purchase_timestamp), '%Y-%m') AS cohort_month
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),
customer_months AS
(
    SELECT DISTINCT
        c.customer_unique_id,
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        ) AS order_month
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
)
SELECT
    fm.cohort_month,
    COUNT(DISTINCT fm.customer_unique_id) AS customers,
    COUNT(
        DISTINCT CASE
            WHEN cm.order_month > fm.cohort_month
            THEN fm.customer_unique_id
        END
    ) AS retained_customers,
    ROUND(
		100 * COUNT(
			DISTINCT CASE
				WHEN cm.order_month > fm.cohort_month
				THEN fm.customer_unique_id
			END
		) / COUNT(DISTINCT fm.customer_unique_id),
        2
	) AS retention_rate_pct
FROM customer_first_month fm
LEFT JOIN customer_months cm
    ON fm.customer_unique_id = cm.customer_unique_id
GROUP BY fm.cohort_month
ORDER BY fm.cohort_month;

-- ========================================================================================
-- 9. Customer Churn Analysis
-- ========================================================================================

-- Why:
-- Identifies customers who have not purchased within the last 90 days of the dataset,
-- helping highlight potentially churned customers and retention opportunities.

WITH customer_last_order AS
(
    SELECT
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp) AS last_order_date
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),
churn_status AS
(
    SELECT
        customer_unique_id,
        last_order_date,
        CASE
            WHEN DATEDIFF(
                (SELECT MAX(order_purchase_timestamp) FROM orders),
                last_order_date
            ) > 90
            THEN 'Potentially Churned'
            ELSE 'Active'
        END AS customer_status
    FROM customer_last_order
)
SELECT
    customer_status,
    COUNT(*) AS total_customers,
    ROUND(
        100 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_share_pct
FROM churn_status
GROUP BY customer_status
ORDER BY total_customers DESC;

-- Insight:
-- 86,524 customers (90.04%) are potentially churned, while only 9,572 (9.96%)
-- are active, indicating a large share of customers have been inactive for over 90 days.

-- ========================================================================================
-- 10. High-Revenue Customers With Few Orders
-- ========================================================================================

-- Why:
-- Identifies customers generating high revenue with few orders,
-- helping identify customers with high average order values.

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(op.payment_value) AS total_spending,
    ROUND(
        SUM(op.payment_value) / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_payments op
    ON o.order_id = op.order_id
GROUP BY c.customer_unique_id
HAVING COUNT(DISTINCT o.order_id) <= 3
ORDER BY total_spending DESC
LIMIT 20;

-- ========================================================================================
-- 11. Average Delivery Time by Customer State
-- ========================================================================================

-- Why:
-- Identifies states with longer delivery times,
-- helping highlight regions that may need logistics improvement.

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
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC;

-- Insight:
-- Roraima (RR) has the highest average delivery time at 28.98 days,
-- followed by Amapa (AP) (26.73) and Amazonas (AM) (25.99), indicating slower delivery
-- in several northern states.

-- ========================================================================================
-- 12. Late Delivery Rate by Customer State
-- ========================================================================================

-- Why:
-- Shows where late deliveries are most common,
-- helping identify regions with potential logistics issues.

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    SUM(
        CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS late_deliveries,
    ROUND(
        100 * AVG(
            CASE
                WHEN o.order_delivered_customer_date >
                     o.order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ),
        2
    ) AS late_delivery_rate_pct
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY late_delivery_rate_pct DESC;

-- Insight:
-- Alagoas (AL) has the highest late-delivery rate at 23.93%, followed by
-- Maranhao (MA) at 19.67% and Piaui (PI) at 15.97%, indicating higher delivery
-- delays in these states.

-- ========================================================================================
-- 13. Year-over-Year Revenue Growth by Product Category
-- ========================================================================================

-- Why:
-- Identifies categories with increasing or declining revenue,
-- helping highlight categories gaining or losing sales momentum.

WITH category_yearly_sales AS
(
    SELECT
        YEAR(o.order_purchase_timestamp) AS order_year,
        COALESCE(
            t.product_category_name_english,
            p.product_category_name
        ) AS product_category,
        SUM(oi.price) AS total_sales
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_translation t
        ON p.product_category_name = t.product_category_name
	WHERE p.product_category_name IS NOT NULL
    GROUP BY
        YEAR(o.order_purchase_timestamp),
        COALESCE(
            t.product_category_name_english,
            p.product_category_name
        )
),
category_growth AS
(
    SELECT
        order_year,
        product_category,
        total_sales,
        LAG(total_sales) OVER (
            PARTITION BY product_category
            ORDER BY order_year
        ) AS previous_year_sales
    FROM category_yearly_sales
)
SELECT
    *,
    ROUND(
        100 * (total_sales - previous_year_sales) /
        NULLIF(previous_year_sales, 0),
        2
    ) AS yoy_growth_pct
FROM category_growth
WHERE previous_year_sales IS NOT NULL;

-- ========================================================================================
-- 14. Revenue Concentration Among Top 10% of Sellers
-- ========================================================================================

-- Why:
-- Measures how much revenue comes from the top sellers,
-- helping assess the business's dependence on a small group of sellers.

WITH seller_sales AS
(
    SELECT
        seller_id,
        SUM(price) AS total_sales
    FROM order_items
    GROUP BY seller_id
),
ranked_sellers AS
(
    SELECT
        seller_id,
        total_sales,
        NTILE(10) OVER (
            ORDER BY total_sales DESC
        ) AS seller_decile
    FROM seller_sales
)
SELECT
    ROUND(
        100 * SUM(
            CASE
                WHEN seller_decile = 1
                THEN total_sales
                ELSE 0
            END
        ) / SUM(total_sales),
        2
    ) AS top_10_percent_revenue_share
FROM ranked_sellers;

-- Insight:
-- The top 10% of sellers generate 67.56% of total sales,
-- indicating a high concentration of revenue among a relatively small group of sellers.

-- ========================================================================================
-- 15. Monthly Sales and Cumulative Revenue
-- ========================================================================================

-- Why:
-- Identifies monthly sales patterns and cumulative revenue growth,
-- helping understand overall revenue progression over time.

WITH monthly_sales AS
(
    SELECT
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        ) AS order_month,
        SUM(op.payment_value) AS monthly_sales
    FROM orders o
    JOIN order_payments op
        ON o.order_id = op.order_id
    GROUP BY
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        )
)
SELECT
    order_month,
    monthly_sales,
    SUM(monthly_sales) OVER (
            ORDER BY order_month
        ) AS cumulative_sales
FROM monthly_sales;

-- ========================================================================================
-- 16. Top 3 States by Revenue Contribution
-- ========================================================================================

-- Why:
-- Identifies the states generating the most revenue,
-- helping assess geographic revenue concentration.

WITH state_revenue AS
(
    SELECT
        c.customer_state,
        SUM(op.payment_value) AS total_revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_payments op
        ON o.order_id = op.order_id
    GROUP BY c.customer_state
)
SELECT
    customer_state,
    total_revenue,
    SUM(total_revenue) OVER (
            ORDER BY total_revenue DESC
        ) AS cumulative_revenue,
    ROUND(
        100 * SUM(total_revenue) OVER (
            ORDER BY total_revenue DESC
        ) / SUM(total_revenue) OVER (),
        2
    ) AS cumulative_revenue_pct
FROM state_revenue
ORDER BY total_revenue DESC
LIMIT 3;

-- Insight:
-- Sao Paulo (SP) generates the highest revenue at 5.99M, followed by Rio de Janeiro (RJ)
-- at 2.14M and Minas Gerais (MG) at 1.87M. Together, these top 3 states contribute
-- 62.56% of total revenue, indicating a strong concentration of revenue in these states.

-- ========================================================================================
-- End of Business Analysis
-- ========================================================================================
