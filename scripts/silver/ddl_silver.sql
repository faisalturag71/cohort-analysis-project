/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'Silver' Tables
===============================================================================
*/

IF OBJECT_ID('silver.online_retail', 'U') IS NOT NULL
    DROP TABLE silver.online_retail;
GO

CREATE TABLE silver.online_retail (
    [InvoiceNo] nvarchar(7),
    [StockCode] nvarchar(7),
    [Description] nvarchar(35),
    [Quantity] smallint,
    [InvoiceDate] datetime,
    [UnitPrice] real,
    [CustomerID] smallint,
    [Country] nvarchar(14)
);
GO
