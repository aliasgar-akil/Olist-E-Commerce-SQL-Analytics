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

| Stage | Description |
|---|---|
| **01. Database Setup** | Create the database, tables, and relationships required for analysis. |
| **02. Data Import** | Import the Olist datasets into the database. |
| **03. Data Validation** | Perform data quality and consistency checks to ensure the data is suitable for analysis. |
| **04. Exploratory Analysis** | Explore customers, orders, products, sellers, payments, and delivery patterns. |
| **05. Business Analysis** | Answer real-world business questions and identify key business insights. |

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
