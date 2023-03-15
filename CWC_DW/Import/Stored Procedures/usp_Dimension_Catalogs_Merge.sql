
CREATE PROC [Import].[usp_Dimension_Catalogs_Merge]
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY
	DECLARE @procedureUpdateKey_ AS INT = 0
		,@USER AS VARCHAR(20) = current_user
		,@date AS SMALLDATETIME = getdate()
		,@stored_procedure_name VARCHAR(50) = OBJECT_NAME(@@PROCID);

	EXEC Administration.usp_Procedure_Updates_Insert @procedureName = @stored_procedure_name
		,@procedureUpdateKey = @procedureUpdateKey_ OUTPUT;

	WITH src
	AS (
		SELECT [Catalog_Number] = [CATALOGNUMBER]
			,[Catalog_Name] = [FRIENDLYNAME]
			,[Catalog_Description] = NULLIF([DESCRIPTION], '')
			,[Catalog_Drop_Date] = CAST([VALIDFROMDATE] AS DATE)
			,[is_Removed_From_Source] = CAST(0 AS BIT)
			,[is_Excluded] = CAST(0 AS BIT)
			,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Count] = CAST(1 AS TINYINT)
		FROM [AX_PRODUCTION].[dbo].[RetailCatalogStaging]
		)
		,tgt
	AS (
		SELECT *
		FROM [CWC_DW].[Dimension].[Catalogs]
		)
	MERGE INTO tgt
	USING src
		ON tgt.[Catalog_Number] = src.[Catalog_Number]
	WHEN NOT MATCHED
		THEN
			INSERT (
				[Catalog_Number]
				,[Catalog_Name]
				,[Catalog_Description]
				,[Catalog_Drop_Date]
				,[is_Removed_From_Source]
				,[is_Excluded]
				,[ETL_Created_Date]
				,[ETL_Modified_Date]
				,[ETL_Modified_Count]
				)
			VALUES (
				src.[Catalog_Number]
				,src.[Catalog_Name]
				,src.[Catalog_Description]
				,src.[Catalog_Drop_Date]
				,src.[is_Removed_From_Source]
				,src.[is_Excluded]
				,src.[ETL_Created_Date]
				,src.[ETL_Modified_Date]
				,src.[ETL_Modified_Count]
				)
	WHEN MATCHED
		AND ISNULL(tgt.[Catalog_Name], '') <> ISNULL(src.[Catalog_Name], '')
		OR ISNULL(tgt.[Catalog_Description], '') <> ISNULL(src.[Catalog_Description], '')
		OR ISNULL(tgt.[Catalog_Drop_Date], '') <> ISNULL(src.[Catalog_Drop_Date], '')
		OR ISNULL(src.[is_Removed_From_Source], '') <> ISNULL(tgt.[is_Removed_From_Source], '')
		THEN
			UPDATE
			SET [Catalog_Name] = src.[Catalog_Name]
				,[Catalog_Description] = src.[Catalog_Description]
				,[Catalog_Drop_Date] = src.[Catalog_Drop_Date]
				,[is_Removed_From_Source] = src.[is_Removed_From_Source]
				,[ETL_Modified_Date] = src.[ETL_Modified_Date]
				,[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count], 1) + 1)
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

