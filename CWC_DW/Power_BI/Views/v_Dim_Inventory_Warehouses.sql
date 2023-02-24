

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Power_BI].[v_Dim_Inventory_Warehouses] AS

SELECT [Inventory_Warehouse_Key] = CAST([Inventory_Warehouse_Key] AS SMALLINT)
      ,[Inventory_Warehouse_ID]
      ,[Inventory_Warehouse]
      --,[State_ID]
      --,[Zip_Code]
      ,[Active] = CASE [is_Active] WHEN 1 THEN 'Active' ELSE 'Not Active' END
FROM [CWC_DW].[Dimension].[Inventory_Warehouses] (NOLOCK)
