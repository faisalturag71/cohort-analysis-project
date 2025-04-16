# cohort-analysis-project
Portfolio project with sql server and tableau


---------------------------------------------------------------------------------------------------------------------------------------
-- Cleaned sales data

DROP TABLE IF EXISTS #Retail_Online_Silver;

SELECT
	InvoiceNo,
	StockCode,
	Description,
	Quantity,
	InvoiceDate,
	UnitPrice,
	CustomerID,
	Country
INTO #Retail_Online_Silver
FROM(
	SELECT
		*,
		COUNT(*) OVER(PARTITION BY InvoiceNo,StockCode,Description,Quantity,InvoiceDate,UnitPrice,CustomerID,Country) AS Duplicate_Flag,
		ROW_NUMBER() OVER(PARTITION BY InvoiceNo,StockCode,Description,Quantity,InvoiceDate,UnitPrice,CustomerID,Country ORDER BY InvoiceDate) AS Row_Num
	FROM dbo.Retail_Online
)t
WHERE Row_Num = 1 AND Quantity > 0 AND UnitPrice > 0 AND CustomerID != 0;

SELECT * FROM #Retail_Online_Silver;


-- Cleaned sales data with revenue and month buckets

DROP TABLE IF EXISTS #SalesData

SELECT 
    CustomerID,
    Quantity * UnitPrice AS Revenue,
    CAST(InvoiceDate AS DATE) AS OrderDate,
    DATETRUNC(MONTH,CAST(InvoiceDate AS DATE)) AS OrderMonth
INTO #
FROM #Retail_Online_Silver
WHERE CustomerID IS NOT NULL;
-----------------------------------------------------------------------




-----------------------------------------------------------------------
-- TEST

SELECT
	*
FROM dbo.Retail_Online
WHERE InvoiceNo LIKE 'C%';

SELECT
	*
FROM dbo.Retail_Online
WHERE StockCode = '22752' AND CustomerID = '12471'
ORDER BY InvoiceDate;

SELECT
	*
FROM dbo.Retail_Online
WHERE StockCode = '84347' AND CustomerID != 0
ORDER BY CustomerID, InvoiceDate;

SELECT
	*
FROM (
	SELECT
		*,
		COUNT(*) OVER(PARTITION BY InvoiceNo,StockCode,Description,Quantity,InvoiceDate,UnitPrice,CustomerID,Country) AS Duplicate_Flag,
		ROW_NUMBER() OVER(PARTITION BY InvoiceNo,StockCode,Description,Quantity,InvoiceDate,UnitPrice,CustomerID,Country ORDER BY InvoiceDate) AS Row_Count
	FROM dbo.Retail_Online
	)t
WHERE Duplicate_Flag > 1;


