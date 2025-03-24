/*
=====================================================================================
DDL Script: Create silver Tables
=====================================================================================
Script Purpose:
    - This script creates the table in the 'silver' schema, dropping existing table
	  if it already exist.
	- Run this script to re-define the DDL structure of 'silver' Table.
=====================================================================================
*/

DROP TABLE IF EXISTS silver.railway;

CREATE TABLE silver.railway(
	transaction_id		VARCHAR(50),
	date_of_purchase	DATE,
	time_of_purchase	TIME(0),
	purchase_type		VARCHAR(50),
	payment_method		VARCHAR(50),
	railcard			VARCHAR(50),
	ticket_class		VARCHAR(50),
	ticket_type			VARCHAR(50),
	price				INT,
	departure_station	VARCHAR(50),
	arrival_station		VARCHAR(50),
	date_of_journey		DATE,
	departure_time		TIME(0),
	arrival_time		TIME(0),
	actual_arrival_time TIME(0),
	journey_status		VARCHAR(50),
	reason_for_delay	VARCHAR(50),
	refund_request		VARCHAR(50)
);