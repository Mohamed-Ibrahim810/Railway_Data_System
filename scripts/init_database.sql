/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'railway_dwh' after checking if it already exists. 
    If the database exists, it is dropped and recreated.
	Additionally, the script sets up four schemas within the database: 'bronze', 'silver'and 'gold'.
	
WARNING:
    Running this script will drop the entire 'railway_dwh' database if it exists. 
    All data in the database will be permanently deleted.
	Proceed with caution and ensure you have proper backups before running this script.
*/

USE master;
GO

DROP DATABASE IF EXISTS railway_dwh;
CREATE DATABASE railway_dwh
GO

USE railway_dwh;
Go

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;