USE DataWarehouse;
GO

/*CRM*/
/* TABLE bronze.crm_cust_info*/
TRUNCATE TABLE bronze.crm_cust_info;
BULK INSERT bronze.crm_cust_info
FROM 'D:\2025\DATAscience\PORTFOLIO PROJECTS\SQL DATA WAREHOUSE\DWH_Project\datasets\source_crm\cust_info.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR =',',
	TABLOCK
);
SELECT * FROM bronze.crm_cust_info
SELECT COUNT(*) FROM bronze.crm_cust_info

/*TABLE bronze.crm_prd_info*/
TRUNCATE TABLE bronze.crm_prd_info;
BULK INSERT bronze.crm_prd_info
FROM 'D:\2025\DATAscience\PORTFOLIO PROJECTS\SQL DATA WAREHOUSE\DWH_Project\datasets\source_crm\prd_info.csv'
WITH(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
SELECT * FROM bronze.crm_prd_info;
SELECT COUNT(*) FROM bronze.crm_prd_info;

/*TABLE bronze.crm_sales_details*/
TRUNCATE TABLE bronze.crm_sales_details;
BULK INSERT bronze.crm_sales_details
FROM 'D:\2025\DATAscience\PORTFOLIO PROJECTS\SQL DATA WAREHOUSE\DWH_Project\datasets\source_crm\sales_details.csv'
WITH(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
SELECT * FROM bronze.crm_sales_details;
SELECT COUNT(*) FROM bronze.crm_sales_details;



/*ERP*/
/*TABLE bronze.erp_cust_az12*/
TRUNCATE TABLE bronze.erp_cust_az12;
BULK INSERT bronze.erp_cust_az12
FROM 'D:\2025\DATAscience\PORTFOLIO PROJECTS\SQL DATA WAREHOUSE\DWH_Project\datasets\source_erp\CUST_AZ12.csv'
WITH(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
SELECT * FROM bronze.erp_cust_az12;
SELECT COUNT(*) FROM bronze.erp_cust_az12;

/*TABLE bronze.erp_loc_a101*/
TRUNCATE TABLE bronze.erp_loc_a101;
BULK INSERT bronze.erp_loc_a101
FROM 'D:\2025\DATAscience\PORTFOLIO PROJECTS\SQL DATA WAREHOUSE\DWH_Project\datasets\source_erp\LOC_A101.csv'
WITH(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
SELECT * FROM  bronze.erp_loc_a101;
SELECT COUNT(*) FROM  bronze.erp_loc_a101;

/*TABLE bronze.erp_loc_a101*/
TRUNCATE TABLE bronze.erp_px_cat_g1v2;
BULK INSERT bronze.erp_px_cat_g1v2
FROM 'D:\2025\DATAscience\PORTFOLIO PROJECTS\SQL DATA WAREHOUSE\DWH_Project\datasets\source_erp\PX_CAT_G1V2.csv'
WITH(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
SELECT * FROM  bronze.erp_px_cat_g1v2;
SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2;