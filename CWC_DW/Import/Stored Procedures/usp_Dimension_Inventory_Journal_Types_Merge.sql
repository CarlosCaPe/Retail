
CREATE PROC [Import].[usp_Dimension_Inventory_Journal_Types_Merge]
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
		SELECT DISTINCT [Inventory_Journal_Type_CD] = CAST(JournalNameID AS VARCHAR(5))
			,[Inventory_Journal] = CASE CAST(JournalNameID AS VARCHAR(5))
				WHEN 'IAJ'
					THEN 'Inventory Adjustments'
				WHEN 'IPLCA'
					THEN 'Cycle Count'
				WHEN 'IPLRE'
					THEN 'Receiving Error'
				WHEN 'IPLPP'
					THEN 'Putaway Pending'
				WHEN 'IPLQC'
					THEN 'Quality Control'
				WHEN 'IPLWD'
					THEN 'Warehouse Damage'
				WHEN 'IPLRN'
					THEN 'Returns Journal'
				ELSE CAST(JournalNameID AS VARCHAR(5))
				END
			,[is_Removed_From_Source] = CAST(0 AS BIT)
			--,[is_Excluded] = CAST(0 AS BIT)
			,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Count] = CAST(1 AS TINYINT)
		--INTO [CWC_DW].[Dimension].[Inventory_Journal_Types]
		FROM [Entity_Staging].[dbo].[rsmWMSInventoryJournalStaging] ij
		)
		,tgt
	AS (
		SELECT *
		FROM [CWC_DW].[Dimension].[Inventory_Journal_Types]
		)
	MERGE INTO tgt
	USING src
		ON tgt.[Inventory_Journal_Type_CD] = src.[Inventory_Journal_Type_CD]
	WHEN NOT MATCHED
		THEN
			INSERT (
				[Inventory_Journal_Type_CD]
				,[Inventory_Journal]
				,[is_Removed_From_Source]
				,[ETL_Created_Date]
				,[ETL_Modified_Date]
				,[ETL_Modified_Count]
				)
			VALUES (
				src.[Inventory_Journal_Type_CD]
				,src.[Inventory_Journal]
				,src.[is_Removed_From_Source]
				,src.[ETL_Created_Date]
				,src.[ETL_Modified_Date]
				,src.[ETL_Modified_Count]
				)
	WHEN MATCHED
		AND ISNULL(tgt.[Inventory_Journal], '') <> ISNULL(src.[Inventory_Journal], '')
		OR ISNULL(tgt.[is_Removed_From_Source], '') <> ISNULL(src.[is_Removed_From_Source], '')
		THEN
			UPDATE
			SET [Inventory_Journal] = src.[Inventory_Journal]
				,[is_Removed_From_Source] = src.[is_Removed_From_Source]
				,[ETL_Modified_Date] = src.[ETL_Modified_Date]
				,[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count], 1) + 1)
	WHEN NOT MATCHED BY SOURCE
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