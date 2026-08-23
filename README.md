# Olist-E-Commerce-SQL-Analytics
End-to-end analysis of Olist Brazilian E-Commerce data, using SQL to investigate real-world business questions around customer spending, revenue growth, product categories, seller performance, customer retention, geographic revenue concentration, and delivery performance.

## Project Overview

Olist is a Brazilian e-commerce marketplace that connects sellers with customers across Brazil. The platform provides a wide range of products and manages the order and delivery process between sellers and customers.

This project analyzes the **Brazilian E-Commerce Public Dataset by Olist**, which contains approximately 100,000 orders placed between 2016 and 2018, along with information about customers, orders, products, sellers, payments, and deliveries.

The analysis uses SQL to investigate real-world business questions around **customer spending, revenue growth, product and seller performance, customer retention, geographic revenue concentration, and delivery performance**.

### Data Source

The dataset used in this project is publicly available on Kaggle:

**[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)**

## Business Problem

Olist operates a large e-commerce marketplace with customers, sellers, products, orders, payments, and deliveries across Brazil. With data coming from multiple parts of the business, it can be challenging to understand what drives revenue, which customers and sellers contribute the most value, how effectively customers are being retained, and where delivery performance may affect the customer experience. This project analyzes the available transaction data to identify meaningful patterns and uncover opportunities to improve customer value, revenue performance, and operational efficiency.

## Project Objective

The objective of this project is to use SQL to analyze Olist's e-commerce data, identify key patterns in customer and business performance, and uncover insights that can support better decisions around revenue, customer retention, seller performance, and delivery operations.

## Database Schema

The database consists of seven related tables covering the main areas of the Olist marketplace, including customers, orders, products, sellers, payments, and product categories, as demonstrated in the following **Entity-Relationship Diagram**.

### Entity-Relationship Diagram
<img width="795" height="822" alt="ER_Diagram" src="https://github.com/user-attachments/assets/5c227512-66a7-4f92-b897-858193f595d3" />

## Dataset

The project uses the **Brazilian E-Commerce Public Dataset by Olist**, containing approximately 100,000 orders and related information across customers, orders, products, sellers, payments, and product categories.

| Table | Description | Rows |
|---|---|---:|
| `customers` | Customer information and location | 99,441 |
| `orders` | Order details, status, and timestamps | 99,441 |
| `order_items` | Products included in each order | 112,650 |
| `order_payments` | Payment details for each order | 103,886 |
| `products` | Product details and categories | 32,951 |
| `sellers` | Seller information and location | 3,095 |
| `product_category_translation` | Product category translations | 71 |

The raw CSV files are not included in this repository due to their file size. The dataset can be downloaded from the [Kaggle source](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) and imported using the provided SQL scripts.

## Project Workflow

The project follows a structured workflow, starting with database creation and data import, followed by data validation, exploratory analysis, and business-focused analysis.

| Stage | File | Description |
|---|---|---|
| **01. Database Setup** | `01_Database_Setup.sql` | Creates the database, tables, and relationships required for analysis. |
| **02. Data Import** | `02_Data_Import.sql` | Imports the Olist datasets into the database. |
| **03. Data Validation** | `03_Data_Validation.sql` | Performs data quality and consistency checks to ensure the data is suitable for analysis. |
| **04. Exploratory Analysis** | `04_Exploratory_Data_Analysis.sql` | Explores customers, orders, products, sellers, payments, and delivery patterns. |
| **05. Business Analysis** | `05_Business_Analysis.sql` | Answers real-world business questions and identifies key business insights. |

### Workflow

```text
01 Database Setup
        ↓
02 Data Import
        ↓
03 Data Validation
        ↓
04 Exploratory Analysis
        ↓
05 Business Analysis
```

## Data Validation

Before moving to exploratory and business analysis, the imported data was validated to ensure that it was complete, consistent, and suitable for analysis.

The validation checks covered:

- Row counts across all tables
- Missing values in key business fields
- Negative and invalid product, order item, and payment values
- Order and delivery date consistency
- Product category translation coverage
- Valid categorical values such as order status, payment type, and state
- Order item consistency and items per order
- Customer identity consistency between `customer_id` and `customer_unique_id`
- Referential integrity between customers, orders, products, sellers, and payments

The checks also distinguished expected missing values from potential data-quality issues. For example, missing delivery dates were reviewed against order status, while untranslated product categories were identified and retained as part of the source data.

Overall, the validation confirmed that the data relationships and key business fields were suitable for further analysis.

**File:** `03_Data_Validation.sql`

## Exploratory Analysis

The exploratory analysis provides an initial understanding of the Olist marketplace by examining overall sales and order activity, customer behavior, product and category performance, payment patterns, and delivery performance. The following sections highlight selected results from this analysis.

### Order & Sales Overview

#### Total Orders, Order Items, Sales, and Freight

Provides an overview of the overall marketplace activity and sales generated.

<img width="454" height="51" alt="image" src="https://github.com/user-attachments/assets/994242dd-b52d-49dd-b5d7-c8ce667e0512" />

#### Orders and Sales by Year

Shows how order volume and sales changed across the years covered by the dataset.

<img width="310" height="94" alt="image" src="https://github.com/user-attachments/assets/7d80fac5-4c02-44f1-9e75-a54c9e612cf0" />


### Customer Analysis

#### Customer Distribution by State

Highlights the Brazilian states with the largest customer bases.

<img width="266" height="239" alt="image" src="https://github.com/user-attachments/assets/92e59167-4137-4b0d-8441-d1ce8c7b9124" />

#### One-Time vs Repeat Customers

Shows the distribution of customers based on whether they made a single purchase or returned for additional purchases.

<img width="262" height="69" alt="image" src="https://github.com/user-attachments/assets/0fc93705-9fc7-4c3b-8a43-310290f453b9" />


### Product & Category Analysis

#### Top Product Categories by Sales

Highlights the product categories generating the highest sales.

<img width="285" height="241" alt="image" src="https://github.com/user-attachments/assets/e2255585-52c6-4f98-a7c3-333d9544b2ee" />

#### Top Product Categories by Items Sold

Shows which product categories have the highest sales volume based on the number of items sold.

<img width="276" height="242" alt="image" src="https://github.com/user-attachments/assets/083264a4-6f17-4b25-9f18-7701e450e7aa" />


### Seller Analysis

#### Seller Distribution by State

Highlights the states with the largest seller presence.

<img width="220" height="239" alt="image" src="https://github.com/user-attachments/assets/30db60e5-b9dd-4922-a675-0f9de8c2b5c1" />


### Payment Analysis

#### Payment Method Distribution

Shows the number of payment records and total payment value for each payment method.

<img width="419" height="112" alt="image" src="https://github.com/user-attachments/assets/c56386cb-9a9e-4ca3-bda0-436aeea8d6ca" />


### Delivery Analysis

#### Average Delivery Time and Late Delivery Rate

Shows the average number of days taken to deliver orders and the percentage delivered after the estimated date.

<img width="300" height="48" alt="image" src="https://github.com/user-attachments/assets/8409eda0-5640-4143-a415-ee5c9228b34b" />

<br><br>

**File:** `04_Exploratory_Data_Analysis.sql`


## Business Analysis

The exploratory analysis provides an overview of marketplace performance, but the next step is to understand what is driving that performance from a business perspective. This analysis examines where revenue comes from, which customers and products drive value, how well customers are retained, how sellers and regions perform, and where delivery operations can be improved.

The goal is to turn these findings into actionable insights that help inform decisions around growth opportunities, customer retention, product and seller strategies, and operational improvements.

## Key Business Questions

1. **Which customers generate the highest lifetime value for the business?**

2. **What share of total revenue is contributed by repeat customers?**

3. **Which quarters generate the most revenue, and what does the overall seasonal pattern look like?**

4. **Which product categories contribute the largest share of total revenue?**

5. **Which products are the top revenue contributors within each product category?**

6. **What is the customer retention rate for each first-purchase cohort?**

7. **How many customers are potentially churned based on their recent purchase activity?**

8. **Which customer states have the highest average delivery times?**

9. **What proportion of total revenue is generated by the top 10% of sellers?**

10. **Which customer states generate the most revenue, and what is the cumulative revenue contribution of the top 3 states?**


## Answers to the Key Business Questions

### 1. Which customers generate the highest lifetime value for the business?

<img width="615" height="240" alt="image" src="https://github.com/user-attachments/assets/e215eccb-5a51-43f0-b3a5-adcddfe40f54" />

The highest-value customer generated 13,664.08 in lifetime spending from a single order, while the second-highest customer spent 9,553.02 across three orders, with an average order value of 3,184.34. Several other high-value customers generated more than 6,000 from a single purchase, showing that high customer value is not always driven by repeat purchases and can also come from large individual orders. This highlights the importance of distinguishing between customers who generate value through frequent purchases and those who make high-value individual purchases when evaluating customer value.

### 2. What share of total revenue is contributed by repeat customers?

<img width="513" height="73" alt="image" src="https://github.com/user-attachments/assets/b677371a-5557-47da-8e0c-81070520035a" />

Repeat customers account for only 2,997 customers and contribute 5.90% of total revenue, while 93,098 one-time customers generate 94.10% of revenue. This indicates that Olist's revenue is largely driven by one-time purchases, with a relatively small repeat-customer base. Increasing customer retention and encouraging repeat purchases could therefore create an opportunity to build a more sustainable source of recurring revenue.

### 3. Which quarters generate the most revenue, and what does the overall seasonal pattern look like?

<img width="344" height="115" alt="image" src="https://github.com/user-attachments/assets/224b1287-27d1-4b47-ad56-61424bba824f" />

Across all years combined, Q2 generated the highest revenue at 4.86M, contributing 30.36% of total revenue, followed by Q1 at 25.91% and Q3 at 25.54%. Q4 recorded the lowest revenue at 2.91M (18.19%), indicating a clear seasonal pattern where revenue is strongest during the first half of the year and declines toward the final quarter.

### 4. Which product categories contribute the largest share of total revenue?

<img width="428" height="242" alt="image" src="https://github.com/user-attachments/assets/3cd4b630-5024-4282-9553-cfb7e030d063" />

Health & Beauty is the largest revenue-generating category, contributing 9.38% of total revenue (1.26M), followed by Watches & Gifts at 8.98% and Bed Bath Table at 7.73%. The top five categories together account for approximately 40% of total revenue, indicating that revenue is distributed across several major categories rather than being dependent on a single product segment.

### 5. Which products are the top revenue contributors within each product category?

<img width="585" height="288" alt="image" src="https://github.com/user-attachments/assets/ef73c235-bff8-4791-afe1-5127ba248571" />

The analysis identifies the top three products by revenue within each product category, allowing products to be compared against others in the same category rather than only against the overall product portfolio. The results highlight the leading revenue-generating products across categories and can help identify products that are driving category performance. Due to the large number of product categories, it was not practical to include all categories in the visualization, so the screenshot shows a selected portion of the results.

### 6. What is the customer retention rate for each first-purchase cohort?

<img width="491" height="302" alt="image" src="https://github.com/user-attachments/assets/8c2568a3-6bde-4095-ba28-1bab381108d2" />

The cohort analysis shows that customer retention is generally low across the larger cohorts. For example, the January 2017 cohort had 764 customers but only 33 returned, resulting in a 4.32% retention rate, while the October 2017 cohort had the largest cohort shown at 4,470 customers but only 110 were retained (2.46%). Most of the larger cohorts shown have retention rates between roughly 2.5% and 4.3%, indicating that only a small proportion of customers return after their first purchase. The 100% retention rate for December 2016 is based on just one customer, so it is not representative of overall retention performance.

### 7. How many customers are potentially churned based on their recent purchase activity?

<img width="435" height="69" alt="image" src="https://github.com/user-attachments/assets/e0824d43-57e4-4f60-9ac3-06d632a1bac4" />

The churn analysis defines a customer as potentially churned when they have had no purchase activity for 90 days, while customers who purchased within the last 90 days are classified as active. Based on this definition, 86,524 customers (90.04%) are potentially churned, compared with 9,572 active customers (9.96%). This indicates a substantial level of customer inactivity and highlights a significant opportunity for customer reactivation and retention efforts.

### 8. Which customer states have the highest average delivery times?

<img width="284" height="240" alt="image" src="https://github.com/user-attachments/assets/f2f38f5d-2c38-49e6-ad2a-f0254b479440" />

The results show a clear regional variation in delivery times, with the longest average delivery periods concentrated in the Northern states. Roraima (RR) has the highest average delivery time at 28.98 days, followed by Amapa (AP) at 26.73 days and Amazonas (AM) at 25.99 days. Other states in the top 10, including Alagoas (AL), Para (PA), Maranhao (MA), Sergipe (SE), Ceara (CE), and Acre (AC), also show relatively long delivery times. This concentration suggests that geographic and logistics challenges, particularly in Northern and some Northeastern states, may be contributing to longer delivery times and represent potential areas for operational improvement.

### 9. What proportion of total revenue is generated by the top 10% of sellers?

<img width="248" height="48" alt="image" src="https://github.com/user-attachments/assets/1a03fe36-0f45-44f4-8576-3030da76b523" />

The results show a high concentration of revenue among the top-performing sellers, with the top 10% of sellers generating 67.56% of total revenue. This means a relatively small group of sellers accounts for more than two-thirds of marketplace revenue, indicating a strong dependence on these high-performing sellers.

### 10. Which customer states generate the most revenue, and what is the cumulative revenue contribution of the top 3 states?

<img width="567" height="91" alt="image" src="https://github.com/user-attachments/assets/032c4b2e-5e9d-4a4a-8007-ab522c850628" />

The results show a strong geographic concentration of revenue, with Sao Paulo, Rio de Janeiro, and Minas Gerais together contributing 62.56% of total revenue. Sao Paulo alone accounts for 37.47%, making the Southeast region a critical market for Olist's overall revenue performance.

**File:** `05_Business_Analysis.sql`


## Key Business Insights

The analysis highlights key areas affecting Olist's growth, customer value, and operational performance, helping identify opportunities for improvement and areas that need further attention.

### 1. Strengthen Customer Retention

Only **3.18% of customers are repeat customers**, while **90.04% are classified as potentially churned based on 90 days of inactivity**. Repeat customers currently contribute **5.90% of total revenue**.

This shows a clear opportunity to increase repeat purchases. The business could use **targeted campaigns, personalized recommendations, follow-up messages, and offers** to encourage customers to return.

### 2. Protect Revenue From High-Performing Sellers

The **top 10% of sellers generate 67.56% of total revenue**, showing that marketplace revenue is highly concentrated among a relatively small group of sellers.

These sellers play an important role in overall revenue, so maintaining strong relationships with them should be a priority. At the same time, helping other sellers grow could **reduce the business's reliance on a small group of top sellers**.

### 3. Maintain Strength in Core Markets While Exploring New Regions

**Sao Paulo, Rio de Janeiro, and Minas Gerais contribute 62.56% of total revenue**, making the Southeast region particularly important to Olist's overall performance.

The business should continue to focus on these strong markets while also exploring **ways to increase sales in regions that currently contribute less revenue**, creating a more balanced revenue base.

### 4. Prioritize High-Value Product Categories

The largest revenue contribution comes from **Health & Beauty (9.38%)**, followed by **Watches & Gifts (8.98%)** and **Bed Bath Table (7.73%)**. The top five categories together account for approximately **40% of total revenue**.

These categories are important revenue drivers and could receive greater attention through **better inventory availability, promotions, and marketing**. At the same time, lower-performing categories can be reviewed to identify opportunities for improvement.

### 5. Address Regional Delivery Challenges

The longest average delivery times are concentrated in several Northern states, with **Roraima averaging 28.98 days**, followed by Amapa at **26.73 days** and Amazonas at **25.99 days**.

These differences suggest that delivery performance should be looked at more closely in these regions. The business could review **delivery partners, shipping routes, and logistics operations** to identify ways to reduce delivery times and improve the customer experience.

### 6. Use Seasonal Patterns in Revenue Planning

Across all years combined, **Q2 contributes 30.36% of total revenue**, making it the strongest quarter, while **Q4 contributes 18.19%**.

This seasonal pattern can help the business plan **inventory, marketing campaigns, seller activity, and operational capacity** according to periods of higher and lower demand.
