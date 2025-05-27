/*
===============================================================================================
Script Purpose:
    This stored procedure loads data into the 'gold' schema from the 'silver' schema.
    It performs the following actions:
    - Truncates the fact table ('gold.fact_railway') before loading new data to avoid foreign key conflicts.
    - Deletes and reseeds identity values in dimension tables before inserting new records.
    - Populates dimension tables from 'silver.railway'.
    - Loads fact data into 'gold.fact_railway' by joining dimension tables with 'silver.railway'.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC gold.load_gold;
--------------------------------------------------------------------------------------
Error Handling:
    - In case of any error, "SET XACT_ABORT ON" ensures that the entire transaction is 
      automatically rolled back, preventing partial data loads and preserving data integrity.
    - Error details (message, severity, state, and line number) are printed for debugging.
===============================================================================================
*/

DROP PROCEDURE IF EXISTS gold.load_gold;
GO
CREATE OR ALTER PROCEDURE gold.load_gold AS
BEGIN
	SET XACT_ABORT ON
	BEGIN TRY
		BEGIN TRANSACTION
        -- **TRUNCATE FACT TABLE FIRST to prevent FK conflicts**
		PRINT '---------- fact_railway truncated ----------'
		TRUNCATE TABLE gold.fact_railway

		PRINT '==================================================';
		PRINT '             Loading gold layer';
		PRINT '==================================================';
		---------------------------------------------------------------------------------
		PRINT '---------- dim_ticket truncated ----------'
		DELETE FROM gold.dim_ticket;
		DBCC CHECKIDENT ('gold.dim_ticket', RESEED, 0);

		PRINT '---------- Data lodaed into the dim_ticket ----------'
		INSERT INTO gold.dim_ticket (ticket_type, ticket_class, railcard)
		SELECT DISTINCT 
			ticket_type, 
			ticket_class, 
			railcard 
		FROM silver.railway;
		PRINT'********************************************************************************************'
		---------------------------------------------------------------------------------
		PRINT '---------- dim_payment truncated ----------'
		DELETE FROM gold.dim_payment;
		DBCC CHECKIDENT ('gold.dim_payment', RESEED, 0);

		PRINT '---------- Data lodaed into the dim_payment ----------'
		INSERT INTO gold.dim_payment (purchase_type, payment_method)
		SELECT DISTINCT 
			purchase_type, 
			payment_method
		FROM silver.railway;
		PRINT'********************************************************************************************'
		---------------------------------------------------------------------------------
		PRINT '---------- dim_station truncated ----------'
		DELETE FROM gold.dim_station;
		DBCC CHECKIDENT ('gold.dim_station', RESEED, 0);

		PRINT '---------- Data lodaed into the dim_station ----------'
		INSERT INTO gold.dim_station (station)
		SELECT
		departure_station AS st1
		FROM silver.railway
		UNION
		SELECT
		arrival_station AS st2
		FROM silver.railway
		PRINT'********************************************************************************************'
		---------------------------------------------------------------------------------
		PRINT '---------- dim_journey truncated ----------'
		DELETE FROM gold.dim_journey;
		DBCC CHECKIDENT ('gold.dim_journey', RESEED, 0);

		PRINT '---------- Data lodaed into the dim_journey ----------'
		INSERT INTO gold.dim_journey (journey_status, reason_for_delay, refund_request)
		SELECT DISTINCT 
			journey_status, 
			reason_for_delay,
			refund_request
		FROM silver.railway;
		PRINT'********************************************************************************************'
		---------------------------------------------------------------------------------
		PRINT '---------- dim_date truncated ----------'
		DELETE FROM gold.dim_date;
		DBCC CHECKIDENT ('gold.dim_date', RESEED, 0);

		PRINT '---------- Data lodaed into the dim_date ----------'
		INSERT INTO gold.dim_date (full_date, year, month, day, weekday)
		SELECT DISTINCT 
			full_date, 
			YEAR(full_date), 
			MONTH(full_date), 
			DAY(full_date), 
			DATENAME(WEEKDAY, full_date)
		FROM (
			SELECT date_of_purchase AS full_date FROM silver.railway
			UNION
			SELECT date_of_journey AS full_date  FROM silver.railway
		) AS dates;
		PRINT'********************************************************************************************'
		-----------------------------------------------------------------------------
		PRINT '---------- dim_time truncated ----------'
		DELETE FROM gold.dim_time;
		DBCC CHECKIDENT ('gold.dim_time', RESEED, 0);

		PRINT '---------- Data lodaed into the dim_time ----------'
		INSERT INTO gold.dim_time (full_time, hour, minute, period)
		SELECT DISTINCT 
			full_time, 
			DATEPART(HOUR, full_time),
			DATEPART(MINUTE, full_time),
			CASE WHEN DATEPART(HOUR, full_time) < 12 THEN 'AM' ELSE 'PM' END
		FROM (
			SELECT time_of_purchase AS full_time FROM silver.railway
			UNION
			SELECT departure_time AS full_time  FROM silver.railway
			UNION
			SELECT arrival_time AS full_time FROM silver.railway
			UNION
			SELECT actual_arrival_time AS full_time  FROM silver.railway WHERE actual_arrival_time IS NOT NULL
		) AS times;
		PRINT'********************************************************************************************'
		------------------------------------------------------------------------------------------------------
		PRINT '---------- Data lodaed into the fact_railway ----------'
		INSERT INTO gold.fact_railway (
			transaction_id,
			ticket_id,
			payment_id, 
			departure_station_id,
			arrival_station_id, 
			journey_id, price,
			purchase_date_id,
			journey_date_id, 
			purchase_time_id,
			departure_time_id,
			arrival_time_id,
			actual_arrival_time_id
		)
		SELECT 
			s.transaction_id,
			t.ticket_id,
			p.payment_id,
			ds.station_id,
			ar.station_id,
			j.journey_id,
			s.price,
			dp.date_id,
			dj.date_id,
			pt.time_id,
			dt.time_id,
			art.time_id,
			COALESCE(aart.time_id, (SELECT time_id FROM gold.dim_time WHERE full_time IS NULL))
		FROM silver.railway s
		LEFT JOIN gold.dim_ticket t 
			ON s.ticket_type = t.ticket_type  
			AND s.ticket_class = t.ticket_class 
			AND s.railcard = t.railcard

		LEFT JOIN gold.dim_payment p 
			ON s.purchase_type = p.purchase_type 
			AND s.payment_method = p.payment_method

		LEFT JOIN gold.dim_station ds 
			ON s.departure_station = ds.station

		LEFT JOIN gold.dim_station ar 
			ON s.arrival_station = ar.station

		LEFT JOIN gold.dim_journey j 
			ON s.journey_status = j.journey_status 
			AND s.reason_for_delay = j.reason_for_delay 
			AND s.refund_request = j.refund_request

		LEFT JOIN gold.dim_date dp 
			ON s.date_of_purchase = dp.full_date

		LEFT JOIN gold.dim_date dj 
			ON s.date_of_journey = dj.full_date

		LEFT JOIN gold.dim_time pt 
			ON s.time_of_purchase = pt.full_time

		LEFT JOIN gold.dim_time dt 
			ON s.departure_time = dt.full_time

		LEFT JOIN gold.dim_time art 
			ON s.arrival_time = art.full_time

		LEFT JOIN gold.dim_time aart 
			ON s.actual_arrival_time = aart.full_time;
			PRINT'********************************************************************************************'
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
				PRINT'=================================='
				PRINT'        !! ERROR OCCURD !!'
				PRINT'=================================='

        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR);
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
	END CATCH;
END;

