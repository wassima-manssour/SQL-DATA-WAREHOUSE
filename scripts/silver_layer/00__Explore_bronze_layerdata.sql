SELECT TOP (1000) [cst_id]
      ,[cst_key]
      ,[cst_firstname]
      ,[cst_lastanme]
      ,[cst_material_status]
      ,[cst_gndr]
      ,[cst_create_date]
  FROM [DataWarehouse].[bronze].[crm_cust_info]

SELECT TOP (1000) * FROM bronze.crm_prd_info;
SELECT TOP (1000) * FROM bronze.crm_sales_details;

SELECT TOP (1000) * FROM bronze.erp_cust_az12;
SELECT TOP (1000) * FROM bronze.erp_loc_a101;
SELECT TOP (1000) * FROM bronze.erp_px_cat_g1v2;