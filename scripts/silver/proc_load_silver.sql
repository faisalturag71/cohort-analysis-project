/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';


		-- Loading silver.online_retail
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.online_retail';
		TRUNCATE TABLE silver.online_retail;
		PRINT '>> Inserting Data Into: silver.online_retail';
		INSERT INTO silver.online_retail (
			InvoiceNo,
			StockCode,
			Description,
			Quantity,
			InvoiceDate,
			UnitPrice,
			CustomerID,
			Country
		)
		SELECT
			InvoiceNo,
			StockCode,
			Description,
			Quantity,
			InvoiceDate,
			UnitPrice,
			CustomerID,
			Country
		FROM(
			SELECT
				*,
				ROW_NUMBER() OVER(PARTITION BY InvoiceNo,StockCode,Description,Quantity,InvoiceDate,UnitPrice,CustomerID,Country ORDER BY InvoiceDate) AS Row_Num
			FROM bronze.online_retail
		)t
		WHERE Row_Num = 1 AND Quantity > 0 AND UnitPrice > 0 AND CustomerID != 0;

		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
		
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END
