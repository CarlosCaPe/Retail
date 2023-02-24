﻿CREATE PROC [Import].[usp_Reference_Inventory_Exclusions_Merge]

AS

WITH src AS
(
SELECT DISTINCT
	 [Item_Number] = ITEMNUMBER
	,[Color_ID] = PRODUCTCOLORID
	,[Size_ID] = PRODUCTSIZEID
	,[is_Removed_From_Source] = CAST(0 AS BIT)
	,[is_Excluded] = CAST(0 AS BIT)
	,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
	,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
	,[ETL_Modified_Count] = CAST(1 AS TINYINT)
--INTO CWC_DW.Reference.Inventory_Exclusions
FROM [AX_Production].[dbo].[ITSInventWarehouseInventoryStatusOnHandStaging] i
left outer join [AX_Production].[dbo].[EcoResProductCategoryAssignmentStaging] ca
  on ca.ProductNumber = i.ItemNumber
left outer join [AX_Production].[dbo].[EcoResProductCategoryStaging] ch
  on ch.CategoryName = ca.ProductCategoryName
where ch.PRODUCTCATEGORYHIERARCHYNAME != 'Retail Product Hierarchy'
and ch.ParentProductCategoryName = 'Exclusion'
)
,tgt AS (SELECT * FROM [CWC_DW].[Reference].[Inventory_Exclusions] (NOLOCK))

MERGE INTO tgt USING src
	ON tgt.[Item_Number] = src.[Item_Number]
   AND tgt.[Color_ID] = src.[Color_ID]
   AND tgt.[Size_ID] = src.[Size_ID]
		WHEN NOT MATCHED THEN
			INSERT([Item_Number],[Color_ID],[Size_ID],[is_Removed_From_Source],[is_Excluded],[ETL_Created_Date],[ETL_Modified_Date],[ETL_Modified_Count])
			VALUES(src.[Item_Number],src.[Color_ID],src.[Size_ID],src.[is_Removed_From_Source],src.[is_Excluded],src.[ETL_Created_Date],src.[ETL_Modified_Date],src.[ETL_Modified_Count])
		WHEN NOT MATCHED BY SOURCE AND tgt.[is_Removed_From_Source] <> 1 THEN UPDATE SET
				 tgt.[is_Removed_From_Source] = 1
				,tgt.[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
				,tgt.[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1);