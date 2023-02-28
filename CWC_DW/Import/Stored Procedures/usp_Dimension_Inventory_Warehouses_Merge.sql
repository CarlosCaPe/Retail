
/****** Script for SelectTopNRows command from SSMS  ******/

CREATE PROC [Import].[usp_Dimension_Inventory_Warehouses_Merge] AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	WITH src AS
		(
			   SELECT
					 [Inventory_Warehouse_ID] = [WAREHOUSEID]
					,[Inventory_Warehouse] = NULLIF([WAREHOUSENAME],'')
					,[State_ID] = NULLIF([PRIMARYADDRESSSTATEID],'')
					,[Zip_Code] = NULLIF([PRIMARYADDRESSZIPCODE],'')
					,[is_Active] = ISNULL(w.is_Active,1)
					--,[is_Removed_From_Source] = CAST(0 AS BIT)
					--,[is_Excluded] = CAST(0 AS BIT)
					--,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
					--,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
					--,[ETL_Modified_Count] = CAST(1 AS TINYINT)
				FROM [AX_PRODUCTION].[dbo].[InventWarehouseStaging] iw
				LEFT JOIN [CWC_DW].[Dimension].[Inventory_Warehouses] w ON iw.[WAREHOUSEID] = w.Inventory_Warehouse_ID
		)
	,tgt AS (SELECT * FROM [CWC_DW].[Dimension].[Inventory_Warehouses])

	MERGE INTO tgt USING src
		ON tgt.[Inventory_Warehouse_ID] = src.[Inventory_Warehouse_ID]
			WHEN NOT MATCHED THEN
				INSERT([Inventory_Warehouse_ID],[Inventory_Warehouse],[State_ID],[Zip_Code],[is_Active])
				VALUES(src.[Inventory_Warehouse_ID],src.[Inventory_Warehouse],src.[State_ID],src.[Zip_Code],src.[is_Active])
			WHEN MATCHED AND
				ISNULL(src.[Inventory_Warehouse],'') <> ISNULL(tgt.[Inventory_Warehouse],'')
			 OR ISNULL(src.[State_ID],'') <> ISNULL(tgt.[State_ID],'')
			 OR ISNULL(src.[Zip_Code],'') <> ISNULL(tgt.[Zip_Code],'')
			THEN UPDATE SET
				[Inventory_Warehouse] = src.[Inventory_Warehouse]
			WHEN NOT MATCHED BY SOURCE AND tgt.[is_Active] <> 0 THEN UPDATE SET
				tgt.[is_Active] = 0
		
			;
END TRY

BEGIN CATCH

	DECLARE @InputParameters NVARCHAR(MAX)
	If @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT @InputParameters = '';
	EXEC Administration.usp_ErrorLogger_Insert @InputParameters;

END CATCH