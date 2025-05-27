/*-
===============================================================================
DDL Script: Create Gold Tables
===============================================================================
Script Purpose:
    - This script creates the tables in the 'gold' schema, dropping existing table
	  if it already exist
	- Run this script to re-define the DDL structure of 'gold' Table
===============================================================================
*/

DROP TABLE IF EXISTS gold.dim_ticket;
CREATE TABLE gold.dim_ticket(
	ticket_id		INT IDENTITY(1,1) PRIMARY KEY,
	ticket_type		VARCHAR(50),
	ticket_class	VARCHAR(50),
	railcard		VARCHAR(50)
);

DROP TABLE IF EXISTS gold.dim_payment;
CREATE TABLE gold.dim_payment (
    payment_id		INT IDENTITY(1,1) PRIMARY KEY,
    purchase_type	VARCHAR(50),
    payment_method	VARCHAR(50)
);

DROP TABLE IF EXISTS gold.dim_station;
CREATE TABLE gold.dim_station (
    station_id	INT IDENTITY(1,1) PRIMARY KEY,
    station		VARCHAR(100) UNIQUE
);

DROP TABLE IF EXISTS gold.dim_journey;
CREATE TABLE gold.dim_journey (
    journey_id			INT IDENTITY(1,1) PRIMARY KEY,
    journey_status		VARCHAR(50),
    reason_for_delay	VARCHAR(50),
    refund_request		VARCHAR(50)
);

DROP TABLE IF EXISTS gold.dim_date;
CREATE TABLE gold.dim_date (
    date_id		INT IDENTITY(1,1) PRIMARY KEY,
    full_date	DATE UNIQUE NOT NULL,
    year		INT NOT NULL,
    month		INT NOT NULL,
    day			INT NOT NULL,
    weekday		VARCHAR(10) NOT NULL
);

DROP TABLE IF EXISTS gold.dim_time;
CREATE TABLE gold.dim_time (
    time_id		INT IDENTITY(1,1) PRIMARY KEY,
    full_time	TIME UNIQUE NOT NULL,
    hour		INT NOT NULL,
    minute		INT NOT NULL,
    period		VARCHAR(2) CHECK (period IN ('AM', 'PM'))
);


DROP TABLE IF EXISTS gold.fact_railway;
CREATE TABLE gold.fact_railway (
	transaction_id			VARCHAR(50) PRIMARY KEY,
    ticket_id				INT,
    payment_id				INT,
    departure_station_id	INT,
    arrival_station_id		INT,
    journey_id				INT,
	price					INT,
    purchase_date_id		INT,
	journey_date_id			INT,
	purchase_time_id		INT,
	departure_time_id		INT,
	arrival_time_id			INT,
	actual_arrival_time_id	INT NULL

	FOREIGN KEY (ticket_id)				 REFERENCES gold.dim_ticket(ticket_id),
    FOREIGN KEY (payment_id)			 REFERENCES gold.dim_payment(payment_id),
    FOREIGN KEY (departure_station_id)	 REFERENCES gold.dim_station(station_id),
    FOREIGN KEY (arrival_station_id)	 REFERENCES gold.dim_station(station_id),
    FOREIGN KEY (journey_id)			 REFERENCES gold.dim_journey(journey_id),
	FOREIGN KEY (purchase_date_id)		 REFERENCES gold.dim_date(date_id),
    FOREIGN KEY (journey_date_id)		 REFERENCES gold.dim_date(date_id),
	FOREIGN KEY (purchase_time_id)		 REFERENCES gold.dim_time(time_id),
	FOREIGN KEY (departure_time_id)		 REFERENCES gold.dim_time(time_id),
	FOREIGN KEY (arrival_time_id)		 REFERENCES gold.dim_time(time_id),
	FOREIGN KEY (actual_arrival_time_id) REFERENCES gold.dim_time(time_id)
);