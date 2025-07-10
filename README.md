# Datavine: Advanced SQL Analytics Project

## Overview

Datavine is a comprehensive SQL analytics project designed to showcase advanced data modeling, reporting, and business intelligence skills. It demonstrates the full workflow of building a data warehouse, importing data, and performing deep business analysis using SQL.

## Features

- **Robust Data Model**: Star schema with fact and dimension tables for scalable analytics.
- **Automated Database Setup**: Scripts to initialize the database and tables.
- **Data Import**: Ready-to-use CSVs for quick population of the database.
- **Modular SQL Scripts**: Each script addresses a specific business question or analysis.
- **Advanced Reporting**: Customer and product reports with dynamic segmentation and KPIs.
- **Comprehensive Analysis**: Covers magnitude, ranking, segmentation, time-series, cumulative, and part-to-whole analyses.

## Skills Demonstrated

### SQL Fundamentals
- Database and table creation
- Data exploration and profiling
- Aggregations, grouping, and filtering

### Advanced SQL Techniques
- **Window Functions**: RANK, DENSE_RANK, ROW_NUMBER, SUM() OVER, AVG() OVER, LAG
- **Common Table Expressions (CTEs)**: Modular, readable queries for complex logic
- **Dynamic Segmentation**: Customer and product segmentation using CASE and business rules
- **KPI Calculation**: Recency, average order value, average monthly spend, and more
- **Time-Series Analysis**: Year-over-year, month-over-month, and cumulative trends
- **Part-to-Whole Analysis**: Category contributions to overall sales
- **Reusable Views**: For customer and product reporting

### Data Modeling & Business Intelligence
- Star schema design (fact and dimension tables)
- Business-focused reporting (VIP customers, high-performing products, etc.)
- Automated and reproducible analytics pipeline

## Project Structure

```
csv-files/      # Source data (customers, products, sales)
backup/         # Logical backup of the database
scripts/        # Modular SQL scripts for setup and analysis
```

## How to Use

1. **Initialize the Database**
   - Run `scripts/00_init_database.sql` to create the schema and tables.

2. **Import Data**
   - Load the CSVs from `csv-files/` into the corresponding tables.

3. **Run Analysis Scripts**
   - Execute scripts in `scripts/` for various analyses and reports.

## Example Analyses

- Top 5 products by revenue
- Customer segmentation (VIP, Regular, New)
- Year-over-year sales trends
- Category-wise sales contribution
- Cumulative and moving average sales

## Sample Outputs

### Top 5 Products by Revenue

```sql
-- Top 5 products generating the highest revenue (from 06_ranking_analysis.sql)
SELECT *
FROM (
    SELECT
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
    FROM fact_sales f
    LEFT JOIN dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.product_name
) AS ranked_products
WHERE rank_products <= 5;
```

![Top 5 Products by Revenue](images/top_5_products.png)
*Replace this image with a screenshot of the query result from the ranking analysis script (06_ranking_analysis.sql).* 

### Customer Segmentation (VIP, Regular, New)

```sql
-- Customer segmentation by spending and history (from 10_data_segmentation.sql)
WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        timestampdiff(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM fact_sales f
    LEFT JOIN dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT 
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT 
        customer_key,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;
```

![Customer Segmentation](images/customer_segmentation.png)
*Replace this image with a screenshot of the segmentation result from the data segmentation script (10_data_segmentation.sql) or customer report (12_report_customers.sql).* 

### Year-over-Year Sales Trend

```sql
-- Year-over-year sales trend (from 09_performance_analysis.sql)
WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM fact_sales f
    LEFT JOIN dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
        YEAR(f.order_date),
        p.product_name
)
SELECT
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
    -- Year-over-Year Analysis
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
    CASE 
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change
FROM yearly_product_sales
ORDER BY product_name, order_year;

```

![Year-over-Year Sales Trend](images/yearly_sales_trend.png)
*Replace this image with a screenshot of the year-over-year sales trend from the performance analysis script (09_performance_analysis.sql).* 

### Category Contribution to Total Sales

```sql
-- Category contribution to total sales (from 11_part_to_whole_analysis.sql)
WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM dim_products p
     JOIN fact_sales f
        ON p.product_key = f.product_key
    GROUP BY p.category
)
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER()) * 100, 2) AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;
```

![Category Contribution](images/category_contribution.png)
*Replace this image with a screenshot of the part-to-whole analysis result from script (11_part_to_whole_analysis.sql).* 

### Sample Customer Report

```sql
-- Sample customer report (from 12_report_customers.sql)
SELECT * FROM report_customers LIMIT 10;
```

![Sample Customer Report](images/sample_customer_report.png)
*Replace this image with a screenshot of a few rows from the customer report view (12_report_customers.sql).* 

## Technologies

- SQL (MySQL syntax, but adaptable to other RDBMS)
- CSV for data import/export

## License

MIT

---

**This project demonstrates my ability to design, implement, and analyze data using advanced SQL techniques, making it ideal for roles in data engineering, analytics, and business intelligence.**
