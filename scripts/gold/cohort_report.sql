/*
===============================================================================
Cohort Report
===============================================================================
Purpose:
    - This report consolidates key cohort metrics and behaviors

Highlights:
    0. Create indexes for performance optimizaiton. 
    1. Remove Dupicates and irrelevant rows. 
    2. Derrive primary fields(cohort month and revenue) for cohort analysis. 
    3. Aggregate monthly active users and revenue with cumulative revenue.
    4. Initial customer count and revenue at Month 0
    5. Final Tableau-ready metrics: CustomerRetentionRate, RevenueRetentionRate, CustomerLifetimeRevenue
===============================================================================
*/

-- =============================================================================
-- Create Index:
-- =============================================================================


-- Primary filtering + partitioning columns:
CREATE NONCLUSTERED INDEX idx_online_retail_main
ON bronze.online_retail (CustomerID, InvoiceDate)
INCLUDE (Quantity, UnitPrice, InvoiceNo, StockCode, Description, Country);
GO

-- =============================================================================
-- Create Report:
-- =============================================================================

--1. gold.vw_cohort_sales : Base data for cohort analysis

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

 --2. gold.vw_cohort_metrics: Aggregate customer activity and revenue by cohort and month

  CREATE OR ALTER VIEW gold.vw_cohort_metrics AS
SELECT
    CohortMonth,
    OrderMonth,
    MonthIndex,
    COUNT(DISTINCT CustomerID) AS ActiveCustomers,
    SUM(Revenue) AS TotalRevenue,
    SUM(SUM(Revenue)) OVER (PARTITION BY CohortMonth ORDER BY MonthIndex 
        			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumulativeRevenue
FROM gold.vw_cohort_sales
GROUP BY CohortMonth, OrderMonth, MonthIndex;
GO

--3.  gold.vw_cohort_summary: Final cohort-level KPIs: retention, LTV, revenue growth with Inline Initial Cohort Stats

CREATE OR ALTER VIEW gold.vw_cohort_summary AS
SELECT 
    cm.CohortMonth,
    cm.MonthIndex,
    CAST(100.0 * cm.ActiveCustomers / NULLIF(ics.InitialCustomers, 0) AS DECIMAL(5,2)) AS CustomerRetentionRate,
    CAST(100.0 * cm.TotalRevenue / NULLIF(ics.InitialRevenue, 0) AS DECIMAL(5,2)) AS RevenueRetentionRate,
    ROUND(cm.CumulativeRevenue / NULLIF(ics.InitialCustomers, 0), 0) AS CustomerLifetimeRevenue,
    ics.CohortSize,
    ics.InitialCohortRevenue
FROM gold.vw_cohort_metrics cm
JOIN (
    SELECT 
        CohortMonth,
        COUNT(DISTINCT CustomerID) AS CohortSize,
        SUM(Revenue) AS InitialCohortRevenue
    FROM gold.vw_cohort_sales
    WHERE MonthIndex = 0
    GROUP BY CohortMonth
) ics ON cm.CohortMonth = ics.CohortMonth;
GO
