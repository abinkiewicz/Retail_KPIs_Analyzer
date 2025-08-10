CREATE DATABASE retail_db;

\c retail_db

CREATE TABLE retail_data (
    InvoiceNo TEXT,
    StockCode TEXT,
    Description TEXT,
    Quantity INT,
    InvoiceDate TIMESTAMP,
    UnitPrice NUMERIC,
    CustomerID TEXT,
    Country TEXT
);

/* ==========================================================
   KPI QUERIES FOR ONLINE RETAIL DATA
   ========================================================== */


/* ==========================================================
   1. Revenue
   Formula: SUM(UnitPrice * Quantity)
   ========================================================== */
SELECT 
    ROUND(SUM(UnitPrice * Quantity), 2) AS total_revenue
FROM retail_data;


/* ==========================================================
   2. ARPU (Average Revenue Per User)
   Formula: SUM(Revenue) / quantity od unique customers
   ========================================================== */
SELECT 
    ROUND(SUM(UnitPrice * Quantity) / COUNT(DISTINCT CustomerID), 2) AS arpu
FROM retail_data
WHERE CustomerID IS NOT NULL;


/* ==========================================================
   3. LTV (Customer Lifetime Value)
   Equals ARPU here - to check!
   ========================================================== */
SELECT 
    ROUND(SUM(UnitPrice * Quantity) / COUNT(DISTINCT CustomerID), 2) AS ltv
FROM retail_data
WHERE CustomerID IS NOT NULL;

/* ==========================================================
   4. Churn Rate (Customers loss)
   Clients percentage with only one transaction
   ========================================================== */
WITH customer_orders AS (
    SELECT 
        CustomerID, 
        COUNT(DISTINCT InvoiceNo) AS orders_count
    FROM retail_data
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
)
SELECT 
    ROUND(100.0 * COUNT(*) FILTER (WHERE orders_count = 1) / COUNT(*), 2) AS churn_rate_percentage
FROM customer_orders;


/* ==========================================================
   5. Retention Rate
   Reverse of churn rate
   ========================================================== */
WITH customer_orders AS (
    SELECT 
        CustomerID, 
        COUNT(DISTINCT InvoiceNo) AS orders_count
    FROM retail_data
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
)
SELECT 
    ROUND(100.0 * COUNT(*) FILTER (WHERE orders_count > 1) / COUNT(*), 2) AS retention_rate_percentage
FROM customer_orders;


/* ==========================================================
   6. Cohort Analysis
   Retention rate regarding the first month
   ========================================================== */
WITH first_purchase AS (
    SELECT
        CustomerID,
        MIN(DATE_TRUNC('month', InvoiceDate)) AS cohort_month
    FROM retail_data
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
),
purchases AS (
    SELECT
        r.CustomerID,
        DATE_TRUNC('month', r.InvoiceDate) AS purchase_month,
        f.cohort_month
    FROM retail_data r
    JOIN first_purchase f USING (CustomerID)
)
SELECT
    cohort_month,
    purchase_month,
    COUNT(DISTINCT CustomerID) AS customers
FROM purchases
GROUP BY cohort_month, purchase_month
ORDER BY cohort_month, purchase_month;


/* ==========================================================
   10. Average Order Value (AOV)
   Formula: SUM(Revenue) / the quantity of orders
   ========================================================== */
SELECT 
    ROUND(SUM(UnitPrice * Quantity) / COUNT(DISTINCT InvoiceNo), 2) AS avg_order_value
FROM retail_data;
