

CREATE PROC [Import].[usp_Dimension_Products_Merge]

AS

WITH src AS
(
SELECT 
	   [Product_Varient_Number] = [PRODUCTVARIENTNUMBER]   
      ,[Department_Name] = NULLIF(NULLIF([DepartmentName],''),'NDF')
      ,[Class_Name] = NULLIF(NULLIF([ClassName],''),'NDF')
      ,[Product_Search_Name] = NULLIF([PRODUCTSEARCHNAME],'')    
      ,[Item_Name] = NULLIF([ItemName],'')
      ,[Color_Name] = NULLIF([ColorName],'')
      ,[Size_Name] = NULLIF([SizeName],'')
      ,[Style_Name] = NULLIF([StyleName],'')
      ,[Sales_Price] = [SalesPrice]
      ,[Sales_Price_Date] = NULLIF(CAST([SalesPriceDate] AS DATE),'1900-01-01')
      ,[Purchase_Price] = [PurchasePrice]
      ,[Purchase_Price_Date] = NULLIF(CAST([PurchasePriceDate] AS DATE),'1900-01-01')
      ,[Vendor_Name] = NULLIF([VendorName],'')
	  ,[Department_ID] = NULLIF(NULLIF([DepartmentId],''),'NDF')
	  ,[Class_ID] = NULLIF(NULLIF([ClassId],''),'NDF')
	  ,[Item_ID] = NULLIF([Itemid],'')
      ,[Color_ID] = NULLIF([ColorId],'')
      ,[Size_ID] = NULLIF([SizeId],'')
      ,[Style_ID] = NULLIF([StyleId],'')
	  ,[Vendor_Account_Number] = NULLIF([VendorAccountNumber],'')
	  ,[is_Active_Product] = CAST(p.ITSIsProductActive AS BIT)
	  ,[is_Currently_Backordered] = CAST(0 AS BIT)
	  --,[Trade_Agreement_Cost] = CAST(tac.Trade_Agreement_Cost AS NUMERIC(18,6))
	  --,[Trade_Agreement_Price] = CAST(tap.Trade_Agreement_Price AS NUMERIC(18,6))
	  ,[Risk] = NULLIF(p.PURCHASECHARGEPRODUCTGROUPID,'')
	  ,[is_Removed_From_Source] = CAST(0 AS BIT)
	  ,[is_Excluded] = CAST(0 AS BIT)
	  ,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
	  ,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
	  ,[ETL_Modified_Count] = CAST(1 AS TINYINT)
  --INTO Dimension.Products
  FROM [AX_PRODUCTION].[dbo].[V_DIM_PRODUCTS] p
  --LEFT JOIN Trade_Agreement_Cost tac ON tac.Item_ID = p.[Itemid] AND tac.Color_ID = p.ColorId AND tac.Size_ID = p.SizeId AND tac.Seq = 1
  --LEFT JOIN Trade_Agreement_Price tap ON tap.Item_ID = p.[Itemid] AND tap.Color_ID = p.ColorId AND tap.Size_ID = p.SizeId AND tap.Seq = 1
  --WHERE [PRODUCTVARIENTNUMBER] IS NULL
)--SELECT * FROM src
,tgt AS (SELECT * FROM [CWC_DW].[Dimension].[Products] (NOLOCK))


MERGE INTO tgt USING src
	ON ISNULL(tgt.[Item_ID],'') = ISNULL(src.[Item_ID],'') AND ISNULL(tgt.[Color_ID],'') = ISNULL(src.[Color_ID],'') AND ISNULL(tgt.[Size_ID],'') = ISNULL(src.[Size_ID],'')
WHEN NOT MATCHED THEN
INSERT([Product_Varient_Number],[Department_Name],[Class_Name],[Product_Search_Name],[Item_Name],[Color_Name],[Size_Name],[Style_Name],[Sales_Price],[Sales_Price_Date],[Purchase_Price]
	 ,[Purchase_Price_Date],[Vendor_Name],[Department_ID],[Class_ID],[Item_ID],[Color_ID],[Size_ID],[Style_ID],[Vendor_Account_Number],[is_Active_Product],[is_Currently_Backordered],/*[Trade_Agreement_Cost],[Trade_Agreement_Price],*/[Risk],[is_Removed_From_Source],[is_Excluded]
     ,[ETL_Created_Date],[ETL_Modified_Date],[ETL_Modified_Count])
VALUES(src.[Product_Varient_Number],src.[Department_Name],src.[Class_Name],src.[Product_Search_Name],src.[Item_Name],src.[Color_Name],src.[Size_Name],src.[Style_Name],src.[Sales_Price],src.[Sales_Price_Date],src.[Purchase_Price]
	 ,src.[Purchase_Price_Date],src.[Vendor_Name],src.[Department_ID],src.[Class_ID],src.[Item_ID],src.[Color_ID],src.[Size_ID],src.[Style_ID],src.[Vendor_Account_Number],src.[is_Active_Product],src.[is_Currently_Backordered],/*src.[Trade_Agreement_Cost],src.[Trade_Agreement_Price],*/src.[Risk],src.[is_Removed_From_Source],src.[is_Excluded]
     ,src.[ETL_Created_Date],src.[ETL_Modified_Date],src.[ETL_Modified_Count])
WHEN MATCHED AND
	   ISNULL(tgt.[Product_Varient_Number],'') <> ISNULL(src.[Product_Varient_Number],'')
	OR ISNULL(tgt.[Department_Name],'') <> ISNULL(src.[Department_Name],'')
	OR ISNULL(tgt.[Class_Name],'') <> ISNULL(src.[Class_Name],'')
	OR ISNULL(tgt.[Product_Search_Name],'') <> ISNULL(src.[Product_Search_Name],'')
	OR ISNULL(tgt.[Item_Name],'') <> ISNULL(src.[Item_Name],'')
	OR ISNULL(tgt.[Color_Name],'') <> ISNULL(src.[Color_Name],'')
	OR ISNULL(tgt.[Size_Name],'') <> ISNULL(src.[Size_Name],'')
	--OR ISNULL(tgt.[Style_Name],'') <> ISNULL(src.[Style_Name],'')
	OR ISNULL(tgt.[Sales_Price],'') <> ISNULL(src.[Sales_Price],'')
	OR ISNULL(tgt.[Sales_Price_Date],'') <> ISNULL(src.[Sales_Price_Date],'')
	OR ISNULL(tgt.[Purchase_Price],'') <> ISNULL(src.[Purchase_Price],'')
	OR ISNULL(tgt.[Purchase_Price_Date],'') <> ISNULL(src.[Purchase_Price_Date],'')
	OR ISNULL(tgt.[Vendor_Name],'') <> ISNULL(src.[Vendor_Name],'')
	OR ISNULL(tgt.[is_Active_Product],'') <> ISNULL(src.[is_Active_Product],'')
	OR ISNULL(tgt.[Department_ID],'') <> ISNULL(src.[Department_ID],'')
	OR ISNULL(tgt.[Class_ID],'') <> ISNULL(src.[Class_ID],'')
	--OR ISNULL(tgt.[Style_ID],'') <> ISNULL(src.[Style_ID],'')
	OR ISNULL(tgt.[Vendor_Account_Number],'') <> ISNULL(src.[Vendor_Account_Number],'')
	--OR ISNULL(tgt.[Trade_Agreement_Cost],0) <> ISNULL(src.[Trade_Agreement_Cost],0)
	--OR ISNULL(tgt.[Trade_Agreement_Price],0) <> ISNULL(src.[Trade_Agreement_Price],0)
	OR ISNULL(tgt.[is_Removed_From_Source],'') <> ISNULL(src.[is_Removed_From_Source],'')
	OR ISNULL(tgt.[Risk],'') <> ISNULL(src.[Risk],'')
THEN UPDATE SET
	 [Product_Varient_Number] = src.[Product_Varient_Number]
	,[Department_Name] = src.[Department_Name]
	,[Class_Name] = src.[Class_Name]
	,[Product_Search_Name] = src.[Product_Search_Name]
	,[Item_Name] = src.[Item_Name]
	,[Color_Name] = src.[Color_Name]
	,[Size_Name] = src.[Size_Name]
	,[Style_Name] = src.[Style_Name]
	,[Sales_Price] = src.[Sales_Price]
	,[Sales_Price_Date] = src.[Sales_Price_Date]
	,[Purchase_Price] = src.[Purchase_Price]
	,[Purchase_Price_Date] = src.[Purchase_Price_Date]
	,[Vendor_Name] = src.[Vendor_Name]
	,[Department_ID] = src.[Department_ID]
	,[Class_ID] = src.[Class_ID]
	,[Style_ID] = src.[Style_ID]
	,[Vendor_Account_Number] = src.[Vendor_Account_Number]
	,[Risk] = src.[Risk]
	,[is_Active_Product] = src.[is_Active_Product]
	--,[Trade_Agreement_Cost] = src.[Trade_Agreement_Cost]
	--,[Trade_Agreement_Price] = src.[Trade_Agreement_Price]
	,[is_Removed_From_Source] = src.[is_Removed_From_Source]
	,[ETL_Modified_Date] = src.[ETL_Modified_Date]
	,[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1)
WHEN NOT MATCHED BY SOURCE AND tgt.[is_Removed_From_Source] <> 1 THEN UPDATE SET
	 tgt.[is_Removed_From_Source] = 1
	,tgt.[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
	,tgt.[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1);
