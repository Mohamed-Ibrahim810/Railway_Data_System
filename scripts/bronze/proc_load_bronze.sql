/*
===============================================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV file (source). 
    It performs the following actions:
    - Truncates the existing bronze tables before loading new data.
    - Uses the BULK INSERT command to efficiently load data into the bronze tables.

Parameters:
    None. 
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
--------------------------------------------------------------------------------------
Error Handling:
    - In case of any error, "SET XACT_ABORT ON" ensures that the entire transaction is 
      automatically rolled back, preventing partial data loads and preserving data integrity.
    - Error details (message, severity, state, and line number) are printed for debugging.
===============================================================================================

*/

DROP PROCEDURE IF EXISTS bronze.load_bronze;
GO
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	SET XACT_ABORT ON
	BEGIN TRY
		BEGIN TRANSACTION
		PRINT '==================================================';
		PRINT '             Loading Bronze Layer';
		PRINT '==================================================';
			TRUNCATE TABLE bronze.railway;
			BULK INSERT bronze.railway
			FROM "C:\Users\medoi\Desktop\Google-Data-Analyst\Projects\Railway_Data_System\source\railway.csv"
			WITH(
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
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