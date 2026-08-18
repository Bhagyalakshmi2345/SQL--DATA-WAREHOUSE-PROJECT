/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/
 
 CREATE OR ALTER   PROCEDURE Bronze.load_bronze AS 
BEGIN
	DECLARE @START_TIME DATETIME,@END_TIME DATETIME
	BEGIN TRY
	PRINT('================================================');
	PRINT('Loading Bronze Layer');
	PRINT('================================================');


	PRINT('---------------------------------------------------');
	PRINT('Loading CRM Tables');
	PRINT('---------------------------------------------------');

	SET @START_TIME = GETDATE(); 
	PRINT'>>TRUNCATING TABLE:Bronze.crm_costore_info';
	TRUNCATE TABLE Bronze.crm_costore_info;

	PRINT'>>INSERTING DATA INTO:Bronze.crm_costore_info';
	BULK INSERT Bronze.crm_costore_info 
	FROM 'C:\Users\BHAGYA LAKSHMI\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
	WITH (
		FIRSTROW =2,
		FIELDTERMINATOR = ',',
		TABLOCK

	);
	SET @END_TIME = GETDATE();
	PRINT '>>LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + 'SECONDS';
	PRINT '-------------'

	SET @START_TIME = GETDATE();
	PRINT'>>TRUNCATING TABLE:Bronze.crm_product_info';
	TRUNCATE TABLE Bronze.crm_product_info;

	PRINT'>>INSERTING DATA INTO:Bronze.crm_product_info';
	BULK INSERT Bronze.crm_product_info 
	FROM 'C:\Users\BHAGYA LAKSHMI\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
	WITH (
		FIRSTROW =2,
		FIELDTERMINATOR = ',',
		TABLOCK

	);
	SET @END_TIME = GETDATE();
	PRINT '>>LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + 'SECONDS';
	PRINT '-------------'

	SET @START_TIME = GETDATE();
	PRINT'>>TRUNCATING TABLE:Bronze.crm_sales_details';
	TRUNCATE TABLE Bronze.crm_sales_details;

	PRINT'>>INSERTING DATA INTO:Bronze.crm_sales_details';
	BULK INSERT Bronze.crm_sales_details 
	FROM 'C:\Users\BHAGYA LAKSHMI\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
	WITH (
		FIRSTROW =2,
		FIELDTERMINATOR = ',',
		TABLOCK

	);
	SET @END_TIME = GETDATE();
	PRINT '>>LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + 'SECONDS';
	PRINT '-------------'


	PRINT('---------------------------------------------------');
	PRINT('Loading ERP Tables');
	PRINT('---------------------------------------------------');

	SET @START_TIME = GETDATE();
	PRINT '>> TRUNCATING TABLE :Bronze.erp_customer_info';
	TRUNCATE TABLE Bronze.erp_customer_info;

	PRINT '>> INSERTING DATA INTO:Bronze.erp_customer_info';
	BULK INSERT Bronze.erp_customer_info 
	FROM 'C:\Users\BHAGYA LAKSHMI\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
	WITH (
		FIRSTROW =2,
		FIELDTERMINATOR = ',',
		TABLOCK

	);
	SET @END_TIME = GETDATE();
	PRINT '>>LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + 'SECONDS';
	PRINT '-------------'


	SET @START_TIME = GETDATE();
	PRINT'>>TRUNCATING TABLE:Bronze.erp_local_info';
	TRUNCATE TABLE Bronze.erp_local_info;

	PRINT'>>INSERTING DATA INTO TABLE:Bronze.erp_local_info';
	BULK INSERT Bronze.erp_local_info 
	FROM 'C:\Users\BHAGYA LAKSHMI\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
	WITH (
		FIRSTROW =2,
		FIELDTERMINATOR = ',',
		TABLOCK

	);
	SET @END_TIME = GETDATE();
	PRINT '>>LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + 'SECONDS';
	PRINT '-------------'

	SET @START_TIME = GETDATE();
	PRINT'>>TRUNCATING TABLE:Bronze.erp_px_cat_info ';
	TRUNCATE TABLE Bronze.erp_px_cat_info;

	PRINT'INSERTING DATA INTO:Bronze.erp_px_cat_info';
	BULK INSERT Bronze.erp_px_cat_info 
	FROM 'C:\Users\BHAGYA LAKSHMI\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
	WITH (
		FIRSTROW =2,
		FIELDTERMINATOR = ',',
		TABLOCK

	);
	SET @END_TIME = GETDATE();
	PRINT '>>LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + 'SECONDS';
	PRINT '-------------'

	END TRY
	BEGIN CATCH
		PRINT'=============================================='
		PRINT'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT'ERRO MESSAGE' + ERROR_MESSAGE();
		PRINT'ERROR MESSAGE'+ CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT'ERROR MESSAGE'+ CAST(ERROR_STATE() AS NVARCHAR);
 
		PRINT'=============================================='
	END CATCH 


END
