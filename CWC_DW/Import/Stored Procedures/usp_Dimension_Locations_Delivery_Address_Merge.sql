
CREATE PROC [Import].[usp_Dimension_Locations_Delivery_Address_Merge]
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY
	DECLARE @procedureUpdateKey_ AS INT = 0
		,@USER AS VARCHAR(20) = current_user
		,@date AS SMALLDATETIME = getdate()
		,@stored_procedure_name VARCHAR(50) = OBJECT_NAME(@@PROCID);

	EXEC Administration.usp_Procedure_Updates_Insert @procedureName = @stored_procedure_name
		,@procedureUpdateKey = @procedureUpdateKey_ OUTPUT;;

	WITH src
	AS (
		SELECT DISTINCT [Street] = CAST(NULLIF(so.[DELIVERYADDRESSSTREET], '') AS VARCHAR(200))
			,[City] = CAST(NULLIF(so.[DELIVERYADDRESSCITY], '') AS VARCHAR(100))
			,[State] = CAST(NULLIF(so.[DELIVERYADDRESSSTATEID], '') AS VARCHAR(5))
			,[Zip_Code] = CAST(NULLIF(so.[DELIVERYADDRESSZIPCODE], '') AS VARCHAR(15))
			,[Country] = CAST(NULLIF(so.[DELIVERYADDRESSCOUNTRYREGIONID], '') AS VARCHAR(10))
			,[is_Removed_From_Source] = CAST(0 AS BIT)
			,[is_Excluded] = CAST(0 AS BIT)
			,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Count] = CAST(1 AS TINYINT) --INTO [CWC_DW].[Dimension].[Locations]  
		FROM [AX_PRODUCTION].[dbo].[ITSSalesOrderHeaderEntityStaging] so
		WHERE (
				NULLIF(so.[DELIVERYADDRESSSTATEID], '') IS NOT NULL
				OR NULLIF(so.[DELIVERYADDRESSZIPCODE], '') IS NOT NULL
				)
		)
		,tgt
	AS (
		SELECT *
		FROM [CWC_DW].[Dimension].[Locations]
		)
	MERGE INTO tgt
	USING src
		ON ISNULL(tgt.[Street], '') = ISNULL(src.[Street], '')
			AND ISNULL(tgt.[City], '') = ISNULL(src.[City], '')
			AND ISNULL(tgt.[State], '') = ISNULL(src.[State], '')
			AND ISNULL(tgt.[Zip_Code], '') = ISNULL(src.[Zip_Code], '')
			AND ISNULL(tgt.[Country], '') = ISNULL(src.[Country], '')
	WHEN NOT MATCHED
		THEN
			INSERT (
				[Street]
				,[City]
				,[State]
				,[Zip_Code]
				,[Country]
				,[is_Removed_From_Source]
				,[is_Excluded]
				,[ETL_Created_Date]
				,[ETL_Modified_Date]
				,[ETL_Modified_Count]
				)
			VALUES (
				src.[Street]
				,src.[City]
				,src.[State]
				,src.[Zip_Code]
				,src.[Country]
				,src.[is_Removed_From_Source]
				,src.[is_Excluded]
				,src.[ETL_Created_Date]
				,src.[ETL_Modified_Date]
				,src.[ETL_Modified_Count]
				);

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