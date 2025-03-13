USE DataWarehouse

-- TRANSFORMATIONS MADE BASED ON THE CHECKS ARE IN THE 'data_transformations.sql' file

/*==========================================================
        crm_cust_info TABLE  checks on bronze layer
===========================================================*/


SELECT TOP(10) * FROM bronze.crm_cust_info
-- CHECK FOR NULLS OR DUPLICATES IN PRIMARY KEY
-- EXPECTATION: NO RESULTS
SELECT cst_id, COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) >1 OR cst_id IS NULL


-- CHECK UNWANTED SPACES ON VARCHAR COLUMNS
/*	if the original value is not equal to the same value after trimming, 
	it means there are spaces!
*/
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);
/*
-- fixing typing error naming the lastname column
SELECT TOP(10) *
FROM bronze.crm_cust_info

EXEC sp_rename 'bronze.crm_cust_info.cst_lastanme', 'cst_lastname', 'COLUMN';
EXEC sp_rename 'bronze.crm_cust_info.cst_material_status', 'cst_marital_status', 'COLUMN';
*/

SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

SELECT cst_key
FROM bronze.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Data Standardization & Consistency
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;


/*==========================================================
        crm_prd_info TABLE checks on BRONZE layer
===========================================================*/

SELECT TOP (10) * FROM bronze.crm_prd_info;
--Check for NULLS or Dupicates in Promary Key
SELECT prd_id, COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*)>1 OR prd_id IS NULL

--Check for unwanted spaces
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

--Check for NULLS or NEGATIVE Numbers
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost<0 OR prd_cost IS NULL

-- Data Standardization & Consistency
SELECT DISTINCT prd_line 
FROM bronze.crm_prd_info

-- Check for Invalid Date Orders (prd_start_dt; prd_end_dt)
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt


/*==========================================================
        crm_sales_details TABLE checks on BRONZE layer
===========================================================*/
SELECT TOP (10) * FROM bronze.crm_sales_details;

-- Check spaces
SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
FROM bronze.crm_sales_details
WHERE sls_ord_num!=TRIM(sls_ord_num);

-- Check if 'sls_prd_key' & 'sls_cust_id' RELATED to the crm_prd_info & crm_cust_info exist in both tables
SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);

SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

-- check for invalide dates (sls_order_dt; sls_ship_dt;	sls_due_dt)
SELECT sls_order_dt, sls_ship_dt,sls_due_dt
FROM bronze.crm_sales_details

SELECT sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt<=0

SELECT sls_order_dt
FROM bronze.crm_sales_details
WHERE LEN(sls_order_dt)!=8

SELECT sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt >20250101 

SELECT sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt >20250101 OR sls_order_dt< 1900101


SELECT 
NULLIF(sls_order_dt,0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt<=0
OR LEN(sls_order_dt)!=8
OR sls_order_dt >20250101 
OR sls_order_dt< 1900101

SELECT 
NULLIF(sls_ship_dt,0) sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt<=0
OR LEN(sls_ship_dt)!=8
OR sls_ship_dt >20250101 
OR sls_ship_dt< 1900101

SELECT 
NULLIF(sls_due_dt,0) sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt<=0
OR LEN(sls_due_dt)!=8
OR sls_due_dt >20250101 
OR sls_due_dt< 1900101

--Check for Invalide date order
SELECT * 
FROM
bronze.crm_sales_details
WHERE sls_order_dt >sls_ship_dt OR sls_order_dt>sls_due_dt

-- Check data consistency of sales quantity & price
-- Sum Sales = quantity * Price
-- negative, zeros, nulls are not allowed

SELECT DISTINCT
	sls_sales, sls_quantity, sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity*sls_price
	OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
	OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
ORDER BY sls_sales, sls_quantity, sls_price

/*==========================================================
        erp_xust_as12 TABLE  checks on bronze layer
===========================================================*/

SELECT TOP (10) * FROM bronze.erp_cust_az12;

--Check valid relation between 'erp_cust_az12' & 'crm_cust_info'
SELECT * FROM silver.crm_cust_info --cid of erp table contains extra NAS not included in cst_id of crm table

SELECT
cid, 
bdate,
gen
FROM bronze.erp_cust_az12
WHERE cid LIKE '%AW00011000%'

--check birthdate out of range
SELECT DISTINCT bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Data standardization & consistency in gender
SELECT DISTINCT gen
FROM bronze.erp_cust_az12 

/*==========================================================
        erp_loc_a101 TABLE  checks on bronze layer
===========================================================*/

--check the relation betwenn crm_cus_info table & erp_loc_a101 on the 'cid' COLUMN
SELECT * FROM bronze.erp_loc_a101;
SELECT cst_key FROM silver.crm_cust_info;

--Data Standardization & consistency (check cntry)
SELECT DISTINCT cntry 
FROM bronze.erp_loc_a101
ORDER BY cntry

/*==========================================================
        erp_px_cat_g1v2 TABLE  checks on bronze layer
===========================================================*/
-- check 'id' for the relationship with crm_prd_info
SELECT * FROM bronze.erp_px_cat_g1v2
SELECT * FROM silver.crm_prd_info

--check unwanted spaces
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE TRIM(cat) != cat OR TRIM(subcat)!=subcat OR TRIM(maintenance)!=maintenance

-- DATA STANDRDAIZATION & CONSISTENCY (check cat)
SELECT DISTINCT 
cat
FROM bronze.erp_px_cat_g1v2
ORDER BY cat

SELECT DISTINCT 
subcat
FROM bronze.erp_px_cat_g1v2
ORDER BY subcat

SELECT DISTINCT 
maintenance
FROM bronze.erp_px_cat_g1v2
ORDER BY maintenance











