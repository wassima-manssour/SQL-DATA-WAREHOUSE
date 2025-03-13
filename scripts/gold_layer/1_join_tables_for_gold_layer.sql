USE DataWarehouse
-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

--join tables for CUSTOMER DIMENSION
SELECT  
    ci.cst_id,
    ci.cst_key,
    ci.cst_firstname,
    ci.cst_lastname,
    ci.cst_marital_status,
    ci.cst_gndr,
    ci. cst_create_date,
	ca.bdate,
	ca.gen,
	la.cntry
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
		ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
		ON ci.cst_key = la.cid

--check for duplicates

SELECT cst_id, COUNT(*) FROM
(SELECT  
    ci.cst_id,
    ci.cst_key,
    ci.cst_firstname,
    ci.cst_lastname,
    ci.cst_marital_status,
    ci.cst_gndr,
    ci. cst_create_date,
	ca.bdate,
	ca.gen,
	la.cntry
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
		ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
		ON ci.cst_key = la.cid
)t GROUP BY cst_id
HAVING COUNT(*)>1

--Data Integretaion on : cst_gndr['crm_cust_info'] & gen ['silver.erp_cust_az1']
SELECT DISTINCT
    ci.cst_gndr,
	ca.gen,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr --CRM is the Master for gender Info
		 ELSE COALESCE(ca.gen,'n/a')
	END AS new_gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
		ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
		ON ci.cst_key = la.cid
ORDER BY 1,2

--Renaming columns following the setted principales
SELECT  
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr --CRM is the Master for gender Info
		 ELSE COALESCE(ca.gen,'n/a')
	END AS gender,
	ca.bdate AS birthdate,
	la.cntry AS country,
	ci. cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
		ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
		ON ci.cst_key = la.cid


--FINAL QUERY (reordering columns, setting the index for the dimension)
SELECT
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key, -- Surrogate key
    ci.cst_id                          AS customer_id,
    ci.cst_key                         AS customer_number,
    ci.cst_firstname                   AS first_name,
    ci.cst_lastname                    AS last_name,
    la.cntry                           AS country,
    ci.cst_marital_status              AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the primary source for gender
        ELSE COALESCE(ca.gen, 'n/a')  			   -- Fallback to ERP data
    END                                AS gender,
    ca.bdate                           AS birthdate,
    ci.cst_create_date                 AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;






-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================

-- Filter out all historical data (keep only current data)
SELECT
    pn.prd_id,
    pn.prd_key,
    pn.prd_nm,
    pn.cat_id,
    pn.prd_cost ,
    pn.prd_line,
    pn.prd_start_dt 
FROM silver.crm_prd_info pn
WHERE pn.prd_end_dt IS NULL;


--join table with product_categories

SELECT
    pn.prd_id,
    pn.prd_key,
    pn.prd_nm,
    pn.cat_id,
    pn.prd_cost ,
    pn.prd_line,
    pn.prd_start_dt,
	pc.cat ,
    pc.subcat ,
    pc.maintenance
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL; -- Filter out all historical data (keep only current data)


--check tha tproduct_key is unique
SELECT prd_key, COUNT(*) FROM 
(SELECT
    pn.prd_id,
    pn.prd_key,
    pn.prd_nm,
    pn.cat_id,
    pn.prd_cost ,
    pn.prd_line,
    pn.prd_start_dt,
	pc.cat ,
    pc.subcat ,
    pc.maintenance
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL) t GROUP BY prd_key
HAVING COUNT(*) >1

--Rename & Sort the columns into logical groups to improve readability
SELECT
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,
    pn.prd_nm       AS product_name,
    pn.cat_id       AS category_id,
    pc.cat          AS category,
    pc.subcat       AS subcategory,
    pc.maintenance  AS maintenance,
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL


--FINAL QUERY (add index)
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, -- Surrogate key
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,
    pn.prd_nm       AS product_name,
    pn.cat_id       AS category_id,
    pc.cat          AS category,
    pc.subcat       AS subcategory,
    pc.maintenance  AS maintenance,
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL; -- Filter out all historical data




-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
SELECT
    sd.sls_ord_num ,
    sd.sls_prd_key ,
	sd.sls_cust_id,
    sd.sls_order_dt,
    sd.sls_ship_dt,
    sd.sls_due_dt,
    sd.sls_sales  ,
    sd.sls_quantity ,
    sd.sls_price
FROM silver.crm_sales_details sd


--join fact table with dimensions
SELECT
    sd.sls_ord_num ,
    pr.product_key ,
    cu.customer_key ,
    sd.sls_order_dt,
    sd.sls_ship_dt,
    sd.sls_due_dt,
    sd.sls_sales  ,
    sd.sls_quantity ,
    sd.sls_price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;

--Rename & Sort the columns into logical groups to improve readability
SELECT
    sd.sls_ord_num  AS order_number,
    pr.product_key  AS product_key,
    cu.customer_key AS customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;









