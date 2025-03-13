USE DataWarehouse


/*==========================================================
        silver.crm_cust_info TABLE checks on SILVER layer
===========================================================*/

SELECT TOP(10) * FROM silver.crm_cust_info
-- CHECK FOR NULLS OR DUPLICATES IN PRIMARY KEY
-- EXPECTATION: NO RESULTS
SELECT cst_id, COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) >1 OR cst_id IS NULL


-- CHECK UNWANTED SPACES ON VARCHAR COLUMNS
/*	if the original value is not equal to the same value after trimming, 
	it means there are spaces!
*/
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);
/*
typing error naming the lastname column
SELECT TOP(10) *
FROM silver.crm_cust_info
EXEC sp_rename 'silver.crm_cust_info.cst_lastanme', 'cst_lastname', 'COLUMN';
EXEC sp_rename 'silver.crm_cust_info.cst_material_status', 'cst_marital_status', 'COLUMN';
cst_marital_status
*/

SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

SELECT cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Data Standardization & Consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;

SELECT * FROM silver.crm_cust_info;

/*==========================================================
        silver.crm_prd_info TABLE checks on SILVER layer
===========================================================*/

SELECT TOP (10) * FROM silver.crm_prd_info;
--Check for NULLS or Dupicates in Promary Key
SELECT prd_id, COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*)>1 OR prd_id IS NULL

--Check for unwanted spaces
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

--Check for NULLS or NEGATIVE Numbers
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost<0 OR prd_cost IS NULL

-- Data Standardization & Consistency
SELECT DISTINCT prd_line 
FROM silver.crm_prd_info

-- Check for Invalid Date Orders (prd_start_dt; prd_end_dt)
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt


SELECT *
FROM silver.crm_prd_info

/*==========================================================
        silver.crm_sales_details TABLE checks on SILVER layer
===========================================================*/
--Check for Invalide date order
SELECT * 
FROM
silver.crm_sales_details
WHERE sls_order_dt >sls_ship_dt OR sls_order_dt>sls_due_dt

SELECT DISTINCT
	sls_sales, sls_quantity, sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity*sls_price
	OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
	OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
ORDER BY sls_sales, sls_quantity, sls_price


SELECT * FROM silver.crm_sales_details




/*==========================================================
        erp_xust_as12 TABLE  checks on bronze layer
===========================================================*/
SELECT
cid, 
bdate,
gen
FROM silver.erp_cust_az12
WHERE cid LIKE '%NAS%'

--check birthdate out of range
SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Data standardization & consistency in gender
SELECT DISTINCT gen
FROM silver.erp_cust_az12 

SELECT * FROM silver.erp_cust_az12 

/*==========================================================
        erp_loc_a101 TABLE  checks on silver layer
===========================================================*/
--check the relation betwenn crm_cus_info table & erp_loc_a101 on the 'cid' COLUMN
SELECT * FROM silver.erp_loc_a101;
SELECT cst_key FROM silver.crm_cust_info;

--Data Standardization & consistency (check cntry)
SELECT DISTINCT cntry 
FROM silver.erp_loc_a101
ORDER BY cntry


/*==========================================================
        erp_px_cat_g1v2 TABLE  checks on silver layer
===========================================================*/
SELECT * FROM silver.erp_px_cat_g1v2


