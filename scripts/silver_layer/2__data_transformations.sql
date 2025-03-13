-- CLEAN & TRANSFORM DATA BASED ON DATA CHECKS RUNNED (check_data_from_bronze_layer.sql)

USE DataWarehouse;

/*==============================================================================
        crm_cust_info TABLE  TRANSFORMATIONS on SILVER layer
===============================================================================*/

SELECT *
FROM bronze.crm_cust_info
WHERE cst_id = 29466;

SELECT *,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info
WHERE cst_id = 29466; 

SELECT *,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info

-- show the duplicates
SELECT * FROM (
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	FROM bronze.crm_cust_info
)t WHERE flag_last!=1;

--keep unique ids 
SELECT * FROM (
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	FROM bronze.crm_cust_info
)t WHERE flag_last=1;



--FINAL TRANSFORMATION QUERY
TRUNCATE TABLE silver.crm_cust_info;
INSERT INTO silver.crm_cust_info (
	cst_id, 
	cst_key, 
	cst_firstname, 
	cst_lastname, 
	cst_marital_status, 
	cst_gndr,
	cst_create_date
)
SELECT
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname, -- delete scpaces in firstname & lastname
	TRIM(cst_lastname) AS cst_lastname,
	--cst_marital_status,
	CASE 
		WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		ELSE 'n/a'
	END AS cst_marital_status, -- Normalize marital status values to readable format
	--cst_gndr,
	CASE 
		WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		ELSE 'n/a'
	END AS cst_gndr, -- Normalize gender values to readable format
	cst_create_date
FROM (
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
)t WHERE flag_last=1; --keep unique cst_id


/*==============================================================================
        crm_prd_info TABLE  TRANSFORMATIONS on SILVER layer
===============================================================================*/

--Extracte category from 'prd_key' to match 'id' in bronze.erp_px_cat_g1v2
SELECT	
	prd_id,
	prd_key,
	SUBSTRING(prd_key,1,5) AS cat_id,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM bronze.crm_prd_info;

SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2; -- erp has'_'delimeter, crm had '-' delimeter
SELECT	
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM bronze.crm_prd_info;

SELECT	
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM bronze.crm_prd_info
WHERE REPLACE(SUBSTRING(prd_key,1,5),'-','_') NOT IN 
	(SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2)
;

-- Extract 'prd_key' to match the 'sls_prd_key' from 'crm_sales_details' table
SELECT	
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
	SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM bronze.crm_prd_info;

-- check the table 'crm_sales_details'
SELECT sls_prd_key FROM bronze.crm_sales_details

--check for the consistency of matching data for join
SELECT	
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
	SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM bronze.crm_prd_info
WHERE SUBSTRING(prd_key,7,LEN(prd_key)) NOT IN (
	SELECT sls_prd_key FROM bronze.crm_sales_details) 


SELECT sls_prd_key FROM bronze.crm_sales_details WHERE sls_prd_key LIKE 'HB-M%' --products with no sales (prd_key from crm_prd_info doesn't exist on the crm_sales_detals

SELECT	
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
	SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM bronze.crm_prd_info
WHERE SUBSTRING(prd_key,7,LEN(prd_key)) IN (
SELECT sls_prd_key FROM bronze.crm_sales_details )


/******** Fix NULLS on prd_cost ******/
SELECT	
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
	SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
	prd_nm,
	ISNULL(prd_cost,0) AS prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM bronze.crm_prd_info

/******** RENAME abreviations in on prd_line ******/

SELECT	
prd_id,
prd_key,
REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
prd_nm,
ISNULL(prd_cost,0) AS prd_cost,
--prd_line,
CASE
	WHEN UPPER(TRIM(prd_line))='M' THEN 'Mountain'
	WHEN UPPER(TRIM(prd_line))='R' THEN 'Road'
	WHEN UPPER(TRIM(prd_line))='S' THEN 'Other Sales'
	WHEN UPPER(TRIM(prd_line))='T' THEN 'Touring'
	ELSE 'n/a'
END AS prd_line,
prd_start_dt,
prd_end_dt
FROM bronze.crm_prd_info
	--QUICK CASE WHEN Ideal for simple value mapping
SELECT	
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
	SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
	prd_nm,
	ISNULL(prd_cost,0) AS prd_cost,
	--prd_line,
	CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a'
	END AS prd_line,
	prd_start_dt,
	prd_end_dt
FROM bronze.crm_prd_info

-- FIX prd_end_dt < prd_start_dt

SELECT
	prd_id,
	prd_key,
	prd_nm,
	prd_start_dt,
	prd_end_dt
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R','AC-HE-HL-U509'); --check 2 records then apply the transformation on all

SELECT
	prd_id,
	prd_key,
	prd_nm,
	prd_start_dt,
	prd_end_dt,
	LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R','AC-HE-HL-U509');



--FINAL TRANSFORMATION QUERY

SELECT	
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
	SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
	prd_nm,
	ISNULL(prd_cost,0) AS prd_cost,
	--prd_line,
	CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a'
	END AS prd_line,
	CAST(prd_start_dt AS DATE) AS prd_start_dt,
	CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info


/*==============================================================================
        crm_sales_details TABLE  TRANSFORMATIONS on SILVER layer
===============================================================================*/

--FIX DATES (0, & CAST)
SELECT 
NULLIF(sls_order_dt,0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt<=0

SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	--sls_order_dt,
	CASE 
		WHEN sls_order_dt = 0 OR LEN(sls_order_dt) !=8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END AS sls_order_dt,
	CASE 
		WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) !=8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END AS sls_ship_dt,
	CASE 
		WHEN sls_due_dt = 0 OR LEN(sls_due_dt) !=8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END AS sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
FROM bronze.crm_sales_details

-- APPLYING BIZ RULES ON (sls_sales, sls_quantity, sls_price) SALES=QUANITYT*PRICE
SELECT DISTINCT
	sls_sales AS old_sls_sales, sls_quantity, sls_price AS old_sls_price,
CASE 
	WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
		THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales, -- Recalculate sales if original value is missing or incorrect sls_quantity
CASE 
	WHEN sls_price IS NULL OR sls_price <= 0 
		THEN sls_sales / NULLIF(sls_quantity, 0)
	ELSE sls_price  -- Derive price if original value is invalid
END AS sls_price
FROM bronze.crm_sales_details;

--FINAL TRANSFORMATION QUERY

SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE 
		WHEN sls_order_dt = 0 OR LEN(sls_order_dt) !=8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END AS sls_order_dt,
	CASE 
		WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) !=8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END AS sls_ship_dt,
	CASE 
		WHEN sls_due_dt = 0 OR LEN(sls_due_dt) !=8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END AS sls_due_dt,
	CASE 
		WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
			THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales, -- Recalculate sales if original value is missing or incorrect sls_quantity
	CASE 
		WHEN sls_price IS NULL OR sls_price <= 0 
			THEN sls_sales / NULLIF(sls_quantity, 0)
		ELSE sls_price  -- Derive price if original value is invalid
	END AS sls_price
FROM bronze.crm_sales_details


/*===========================================================

        erp_xust_as12 TABLE  checks on bronze layer
===========================================================*/

-- FIX the cid<->cst_id  NAS caracters
SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
	 ELSE cid
END AS cid,
bdate,
gen
FROM bronze.erp_cust_az12

--check if it works right
SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
	 ELSE cid
END AS cid,
bdate,
gen
FROM bronze.erp_cust_az12
WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
		ELSE cid
	  END 
NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info)

-- FIX the bdate
SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
	 ELSE cid
END AS cid,

CASE WHEN bdate> GETDATE() THEN NULL
	 ELSE bdate
END AS bdate,
gen
FROM bronze.erp_cust_az12

-- FIX 'gen' colmun
SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
	 ELSE cid
END AS cid,

CASE WHEN bdate> GETDATE() THEN NULL
	 ELSE bdate
END AS bdate,

CASE WHEN UPPER (TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
	 WHEN UPPER (TRIM(gen)) IN ('M','MALE') THEN 'Male'
	 ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12

--check
SELECT DISTINCT gen,
CASE WHEN UPPER (TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
	 WHEN UPPER (TRIM(gen)) IN ('M','MALE') THEN 'Male'
	 ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12

-- FINAL TRANSFORMATION QUERY
SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
	 ELSE cid
END AS cid,

CASE WHEN bdate> GETDATE() THEN NULL
	 ELSE bdate
END AS bdate,

CASE WHEN UPPER (TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
	 WHEN UPPER (TRIM(gen)) IN ('M','MALE') THEN 'Male'
	 ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12

/*==========================================================
        erp_loc_a101 TABLE  checks on bronze layer
===========================================================*/

--Fix '-' on 'cid' for relatoion between betwenn erp_loc_a101 & crm_cus_info table  
SELECT 
REPLACE(cid,'-',''), 
cntry
FROM bronze.erp_loc_a101;

--check if it works
SELECT 
REPLACE(cid,'-','') cid, 
cntry
FROM bronze.erp_loc_a101
WHERE REPLACE(cid,'-','')  NOT IN (SELECT cst_key FROM silver.crm_cust_info)

-- FIX cntry column
SELECT 
REPLACE(cid,'-','') cid, 
CASE WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
	WHEN UPPER(TRIM(cntry)) IN ('US','USA') THEN 'United States'
	WHEN TRIM(cntry) = '' OR TRIM(cntry) IS NULL THEN 'n/a'
	ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101 

--check cntry
SELECT DISTINCT 
cntry AS old_cntry ,
CASE WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germnay'
	WHEN UPPER(TRIM(cntry)) IN ('US','USA') THEN 'United States'
	WHEN TRIM(cntry) = '' OR TRIM(cntry) IS NULL THEN 'n/a'
	ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101 
ORDER BY cntry














