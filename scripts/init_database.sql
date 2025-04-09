/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'CohortDB' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	---------------------------------------------------------
	bronze : For importing the data as is.
	silver : For storing cleaned up data.
	gold : For business ready data.

=============================================================

WARNING:
    Running this script will drop the entire 'CohortDB' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'CohortDB' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'CohortDB')
BEGIN
    ALTER DATABASE CohortDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CohortDB;
END;
GO

-- Create the 'CohortDB' database
CREATE DATABASE CohortDB;
GO

USE CohortDB;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
