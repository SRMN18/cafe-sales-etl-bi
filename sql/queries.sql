-- ============================================================
-- CAFÉ SALES ANALYTICS - CORE SQL QUERIES (SQLite)
-- ============================================================

-- 1. General indicators
SELECT 
    COUNT(*) AS transactions,
    ROUND(SUM("Total Spent"), 2) AS revenue,
    ROUND(AVG("Total Spent"), 2) AS avg_ticket
FROM sales;

-- 2. Sales by payment method
SELECT 
    "Payment Method", 
    COUNT(*) AS n, 
    ROUND(SUM("Total Spent"), 2) AS revenue
FROM sales
GROUP BY "Payment Method"
ORDER BY revenue DESC;

-- 3. Ranking articles (CTE + Window Function RANK)
WITH item_rev AS (
    SELECT 
        "Item", 
        SUM("Total Spent") AS revenue
    FROM sales
    GROUP BY "Item"
)
SELECT 
    "Item", 
    ROUND(revenue, 2) AS revenue,
    RANK() OVER (ORDER BY revenue DESC) AS rnk
FROM item_rev;

-- 4. Sales by each month accumulated (CTE + Running Total Window Function)
WITH monthly AS (
    SELECT 
        strftime('%Y-%m', "Transaction Date") AS month, 
        SUM("Total Spent") AS revenue
    FROM sales
    GROUP BY month
)
SELECT 
    month, 
    ROUND(revenue, 2) AS revenue,
    ROUND(SUM(revenue) OVER (ORDER BY month), 2) AS running_total
FROM monthly;

-- 5. Participation by location and payment method (Window Function PARTITION BY)
SELECT
    "Location",
    "Payment Method",
    ROUND(SUM("Total Spent"), 2) AS revenue,
    ROUND(100.0 * SUM("Total Spent") / SUM("Total Spent") OVER (PARTITION BY "Location"), 1) AS pct_of_location
FROM sales
GROUP BY "Location", "Payment Method"
ORDER BY "Location", revenue DESC;