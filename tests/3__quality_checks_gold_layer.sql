/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency, 
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/
USE DataWarehouse

--DIM CUSTOMERS
SELECT * FROM gold.dim_customers
SELECT DISTINCT gender  FROM gold.dim_customers

--DIM PRODUCTS
SELECT * FROM gold.dim_products

--FACT SALES
SELECT * FROM gold.fact_sales;


SELECT * FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
	ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL



SELECT * FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
	ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
	ON p.product_key = f.product_key
WHERE p.product_key IS NULL


