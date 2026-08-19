/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

--- table of crm.costore

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN 
     DECLARE @START_TIME DATETIME,@END_TIME DATETIME
    BEGIN TRY 
	PRINT('================================================');
	PRINT('Loading Silver Layer');
	PRINT('================================================');


	PRINT('---------------------------------------------------');
	PRINT('Loading CRM Tables');
	PRINT('---------------------------------------------------');


	SET @START_TIME = GETDATE();
	PRINT 'TRUNCATING TABLE:Silver.crm_costore_info';
	TRUNCATE TABLE Silver.crm_costore_info;
	PRINT 'INSERTING DATA INTO :Silver.crm_costore_info';
	INSERT INTO Silver.crm_costore_info (cst_id,cst_key,cst_firstName,cst_lastName,cst_marital_status,cst_gndr,cst_create_date)
	SELECT
		cst_id,
		cst_key,
		TRIM(cst_firstName) AS cst_firstName,
		TRIM(cst_lastName) AS cst_lastName,
		CASE
			 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			 WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
			 ELSE 'N/A'
		END cst_marital_status,

		CASE
			 WHEN UPPER(TRIM(cst_gndr)) ='F' THEN 'Female'
			 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			 ELSE 'N/A'
		END cst_gndr,
		cst_create_date
	FROM(
		SELECT
			*,
			ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC ) as flag_last
		FROM Bronze.crm_costore_info
		WHERE cst_id IS NOT NULL
	) t
	WHERE flag_last = 1
	SET @END_TIME = GETDATE();
	PRINT '>>LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + 'SECONDS';
	PRINT '-------------';

  
 
	 -- table of crm.product
	 SET @START_TIME = GETDATE();
	PRINT 'TRUNCATING TABLE:silver.crm_product_info';
	TRUNCATE TABLE silver.crm_product_info;
	PRINT 'INSERTING DATA INTO :silver.crm_product_info';
	INSERT INTO silver.crm_product_info 
	(	prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
	)
	SELECT 
		prd_id,
 
		REPLACE(SUBSTRING(prd_key,1,5), '-','_') AS cat_id,
		SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
		prd_name,

		ISNULL(prd_cost,0) as prd_cost,

		CASE UPPER(TRIM(prd_line))
			 WHEN  'R' THEN 'Road'
			 WHEN  'M' THEN 'Mountain'
			 WHEN  'S' THEN 'other sales'
			 WHEN 'T' THEN 'Touring'
			 ELSE 'N/A'
		END prd_line,
		CAST(prd_start_date AS DATE) AS prd_start_date,
		CAST(LEAD(prd_start_date) OVER (PARTITION BY prd_key ORDER BY prd_start_date)-1 AS DATE) AS prd_end_date
	FROM Bronze.crm_product_info
		SET @END_TIME = GETDATE();
	PRINT '>>LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + 'SECONDS';
	PRINT '-------------'



	 -- table of crm.sales
	 SET @START_TIME = GETDATE();
	PRINT 'TRUNCATING TABLE:silver.crm_sales_details';
	TRUNCATE TABLE silver.crm_sales_details;
	PRINT 'INSERTING DATA INTO :silver.crm_sales_details';

	INSERT INTO silver.crm_sales_details 
	(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
	)

	SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_date =0 OR LEN(sls_order_date)!=8 THEN NULL
		 ELSE CAST(CAST(sls_order_date AS VARCHAR) AS DATE)
	END AS sls_order_date,
	CASE WHEN sls_ship_date =0 OR LEN(sls_ship_date)!=8 THEN NULL
		 ELSE CAST(CAST(sls_ship_date AS VARCHAR) AS DATE)
	END AS sls_ship_date,
	CASE WHEN sls_due_date =0 OR LEN(sls_due_date )!=8 THEN NULL
		 ELSE CAST(CAST(sls_due_date  AS VARCHAR) AS DATE)
	END AS sls_due_date ,
	CASE WHEN sls_sales IS NULL or sls_sales<=0 or sls_sales!=sls_quantity *ABS(sls_price)
		  THEN sls_quantity * ABS(sls_price)
		  ELSE sls_sales
	 end as sls_sales ,
	 sls_quantity,
	 CASE WHEN sls_price IS NULL or sls_price<=0 
		  THEN sls_sales/NULLIF(sls_quantity,0) 
		  ELSE sls_price
	 end as sls_price 
	FROM Bronze.crm_sales_details
		SET @END_TIME = GETDATE();
	PRINT '>>LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + 'SECONDS';
	PRINT '-------------'
 
 	PRINT('---------------------------------------------------');
	PRINT('Loading ERP Tables');
	PRINT('---------------------------------------------------');
	 -- table of erp.customers
	 SET @START_TIME = GETDATE();
	 PRINT 'TRUNCATING TABLE:silver.erp_customer_info';
	TRUNCATE TABLE silver.erp_customer_info;
	PRINT 'INSERTING DATA INTO :silver.erp_customer_info';
	INSERT INTO silver.erp_customer_info
	(
		cid,
		bdate,
		gen
	)
	SELECT 
	CASE WHEN cust_cid LIKE 'NAS%' THEN SUBSTRING(cust_cid,4,LEN(cust_cid)) 
		 ELSE cust_cid
	END cust_cid,
	CASE WHEN cust_dbirth > GETDATE() THEN NULL
		 ELSE cust_dbirth
	END cust_dbirth,
	CASE  WHEN UPPER(TRIM(cust_gndr)) IN ('F','FEMALE') THEN 'Female'
		  WHEN UPPER(TRIM(cust_gndr)) IN ('M','MALE') THEN 'Male'
		  ELSE 'N/A'
	END cust_gndr
	FROM Bronze.erp_customer_info
		SET @END_TIME = GETDATE();
	PRINT '>>LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + 'SECONDS';
	PRINT '-------------'

	-- table of erp.local
	SET @START_TIME = GETDATE();
	PRINT 'TRUNCATING TABLE:silver.erp_local_info';
	TRUNCATE TABLE silver.erp_local_info;
	PRINT 'INSERTING DATA INTO :silver.erp_local_info';
	 INSERT INTO silver.erp_local_info
	 (
		cid,
		cntry
	 )

	SELECT 
	REPLACE(loc_cid,'-','') AS loc_cid,
	CASE WHEN UPPER(TRIM(loc_cntry)) IN ('US','USA') THEN 'United States'
			WHEN UPPER(TRIM(loc_cntry)) = 'DE' THEN 'Germany'
			WHEN UPPER(TRIM(loc_cntry)) IS NULL OR UPPER(TRIM(loc_cntry)) = '' THEN 'N/A'
			ELSE loc_cntry
	END loc_cntry
	FROM Bronze.erp_local_info
		SET @END_TIME = GETDATE();
	PRINT '>>LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@START_TIME,@END_TIME) AS NVARCHAR) + 'SECONDS';
	PRINT '-------------'

	-- table of erp.cat
	SET @START_TIME = GETDATE();
	PRINT 'TRUNCATING TABLE:silver.erp_px_cat_info';
	TRUNCATE TABLE silver.erp_px_cat_info;
	PRINT 'INSERTING DATA INTO :silver.erp_px_cat_info';

	INSERT INTO silver.erp_px_cat_info
	(
		id,
		cat,
		subcat,
		maintenance
	)

	SELECT 
	px_id,
	px_cat,
	px_subcat,
	px_maintenance
	FROM Bronze.erp_px_cat_info
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
