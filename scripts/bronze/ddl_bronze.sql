/*-
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    - This script creates the table in the 'bronze' schema, dropping existing table
	  if it already exist
	- Run this script to re-define the DDL structure of 'bronze' Table
===============================================================================
*/

DROP TABLE IF EXISTS bronze.railway;

CREATE TABLE bronze.railway(
	TransactionID		VARCHAR(50),
	Date_of_Purchase	DATE,
	Time_of_Purchase	TIME,
	Purchase_Type		VARCHAR(50),
	Payment_Method		VARCHAR(50),
	Railcard			VARCHAR(50),
	Ticket_Class		VARCHAR(50),
	Ticket_Type			VARCHAR(50),
	Price				INT,
	Departure_Station	VARCHAR(50),
	Arrival_Station		VARCHAR(50),
	Date_of_Journey		DATE,
	Departure_Time		TIME,
	Arrival_Time		TIME,
	Actual_Arrival_Time TIME,
	Journey_Status		VARCHAR(50),
	Reason_for_Delay	VARCHAR(50),
	Refund_Request		VARCHAR(50)
);