/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

IF OBJECT_ID('bronze.online_retail', 'U') IS NOT NULL
    DROP TABLE bronze.online_retail;
GO

CREATE TABLE bronze.online_retail (
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
