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
	InvoiceNo	nvarchar(50) null,
	StockCode	nvarchar(50) null,
	Description	nvarchar(50) null,
	Quantity	nvarchar(50) null,
	InvoiceDate	nvarchar(50) null,
	UnitPrice	nvarchar(50) null,
	CustomerID	nvarchar(50) null,
	Country		nvarchar(50) null
);
GO
