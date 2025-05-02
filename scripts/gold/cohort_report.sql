/*
===============================================================================
Cohort Report
===============================================================================
Purpose:
    - This report consolidates key cohort metrics and behaviors

Highlights:
    1. Remove Dupicates and irrelevant rows.
	2. Derrive primary fields(cohort month and revenue) for cohort analysis.
    3. Aggregated monthly active users and revenue with cumulative revenue.
    4. Initial customer count and revenue at Month 0
    5. Final Tableau-ready metrics: CustomerRetentionRate, RevenueRetentionRate, CustomerLifetimeRevenue
===============================================================================
*/

-- =============================================================================
-- Create Report:
-- =============================================================================

--1. gold.vw_cohort_sales

CREATE OR ALTER VIEW gold.vw_cohort_sales AS
SELECT 
    CustomerID,
    CAST(Quantity * UnitPrice AS DECIMAL(18,2)) AS Revenue,
    DATETRUNC(MONTH, InvoiceDate) AS OrderMonth,
    MIN(DATETRUNC(MONTH, InvoiceDate)) OVER(PARTITION BY CustomerID) AS CohortMonth,
    DATEDIFF(
        MONTH,
        MIN(DATETRUNC(MONTH, InvoiceDate)) OVER(PARTITION BY CustomerID),
        DATETRUNC(MONTH, InvoiceDate)
    ) AS MonthIndex
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country
               ORDER BY InvoiceDate
           ) AS rn
    FROM bronze.online_retail
) a
WHERE rn = 1
  AND Quantity > 0 
  AND UnitPrice > 0 
  AND CustomerID IS NOT NULL 
  AND CustomerID != 0
  AND InvoiceNo NOT LIKE 'C%';  -- Exclude cancellations
  GO

 --2. gold.vw_cohort_metrics

  CREATE OR ALTER VIEW gold.vw_cohort_metrics AS
SELECT
    CohortMonth,
    OrderMonth,
    MonthIndex,
    COUNT(DISTINCT CustomerID) AS ActiveCustomers,
    SUM(Revenue) AS TotalRevenue,
    SUM(SUM(Revenue)) OVER (
        PARTITION BY CohortMonth 
        ORDER BY MonthIndex 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS CumulativeRevenue
FROM gold.vw_cohort_sales
GROUP BY CohortMonth, OrderMonth, MonthIndex;
GO

--3. gold.vw_initial_cohort_stats

CREATE OR ALTER VIEW gold.vw_initial_cohort_stats AS
SELECT 
    CohortMonth,
    COUNT(DISTINCT CustomerID) AS InitialCustomers,
    SUM(Revenue) AS InitialRevenue
FROM gold.vw_cohort_sales
WHERE MonthIndex = 0
GROUP BY CohortMonth;
GO


--4. gold.vw_cohort_summary

CREATE OR ALTER VIEW gold.vw_cohort_summary AS
SELECT 
    cm.CohortMonth,
    cm.MonthIndex,
    CAST(100.0 * cm.ActiveCustomers / NULLIF(ics.InitialCustomers, 0) AS DECIMAL(5,2)) AS CustomerRetentionRate,
    CAST(100.0 * cm.TotalRevenue / NULLIF(ics.InitialRevenue, 0) AS DECIMAL(5,2)) AS RevenueRetentionRate,
    ROUND(cm.CumulativeRevenue / NULLIF(ics.InitialCustomers, 0), 0) AS CustomerLifetimeRevenue,
    ics.InitialCustomers,
    ics.InitialRevenue
FROM gold.vw_cohort_metrics cm
JOIN gold.vw_initial_cohort_stats ics ON cm.CohortMonth = ics.CohortMonth;
GO
