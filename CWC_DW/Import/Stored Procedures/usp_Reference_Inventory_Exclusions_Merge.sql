
CREATE PROC [Import].[usp_Reference_Inventory_Exclusions_Merge]
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

BEGIN TRY
	DECLARE @procedureUpdateKey_ AS INT = 0
		,@USER AS VARCHAR(20) = current_user
		,@date AS SMALLDATETIME = getdate()
		,@stored_procedure_name VARCHAR(50) = OBJECT_NAME(@@PROCID);

	EXEC Administration.usp_Procedure_Updates_Insert @procedureName = @stored_procedure_name
		,@procedureUpdateKey = @procedureUpdateKey_ OUTPUT;

	WITH src
	AS (
		SELECT DISTINCT [Item_Number] = ITEMNUMBER
			,[Color_ID] = PRODUCTCOLORID
			,[Size_ID] = PRODUCTSIZEID
			,[is_Removed_From_Source] = CAST(0 AS BIT)
			,[is_Excluded] = CAST(0 AS BIT)
			,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Count] = CAST(1 AS TINYINT)
		FROM [AX_Production].[dbo].[ITSInventWarehouseInventoryStatusOnHandStaging] i
		LEFT OUTER JOIN [AX_Production].[dbo].[EcoResProductCategoryAssignmentStaging] ca ON ca.ProductNumber = i.ItemNumber
		LEFT OUTER JOIN [AX_Production].[dbo].[EcoResProductCategoryStaging] ch ON ch.CategoryName = ca.ProductCategoryName
		WHERE ch.PRODUCTCATEGORYHIERARCHYNAME != 'Retail Product Hierarchy'
			AND ch.ParentProductCategoryName = 'Exclusion'
		)
		,tgt
	AS (
		SELECT *
		FROM [CWC_DW].[Reference].[Inventory_Exclusions]
		)
	MERGE INTO tgt
	USING src
		ON tgt.[Item_Number] = src.[Item_Number]
			AND tgt.[Color_ID] = src.[Color_ID]
			AND tgt.[Size_ID] = src.[Size_ID]
	WHEN NOT MATCHED
		THEN
			INSERT (
				[Item_Number]
				,[Color_ID]
				,[Size_ID]
				,[is_Removed_From_Source]
				,[is_Excluded]
				,[ETL_Created_Date]
				,[ETL_Modified_Date]
				,[ETL_Modified_Count]
				)
			VALUES (
				src.[Item_Number]
				,src.[Color_ID]
				,src.[Size_ID]
				,src.[is_Removed_From_Source]
				,src.[is_Excluded]
				,src.[ETL_Created_Date]
				,src.[ETL_Modified_Date]
				,src.[ETL_Modified_Count]
				)
	WHEN NOT MATCHED BY SOURCE
		AND tgt.[is_Removed_From_Source] <> 1
		THEN
			UPDATE
			SET tgt.[is_Removed_From_Source] = 1
				,tgt.[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
				,tgt.[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count], 1) + 1);

	UPDATE Administration.Procedure_Updates
	SET [Status] = 'SUCCESS'
		,Affected_Rows = @@ROWCOUNT
		,End_Date = getdate()
	WHERE Procedure_Update_Key = @procedureUpdateKey_
END TRY

BEGIN CATCH
	IF @procedureUpdateKey_ <> 0
		UPDATE [Administration].Procedure_Updates
		SET [Status] = 'FAILED'
			,Error = ERROR_MESSAGE()
			,End_Date = getdate()
		WHERE Procedure_Update_Key = @procedureUpdateKey_

	DECLARE @InputParameters NVARCHAR(MAX)

	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SELECT @InputParameters = '';

	EXEC Administration.usp_Error_Logger_Insert @InputParameters;
END CATCH