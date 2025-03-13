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


