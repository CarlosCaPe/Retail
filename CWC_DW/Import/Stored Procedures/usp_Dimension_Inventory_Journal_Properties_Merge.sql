
CREATE PROC [Import].[usp_Dimension_Inventory_Journal_Properties_Merge]
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
		SELECT DISTINCT [Counting_Reason_CD] = COUNTINGREASONCODE
			,[Inventory_Status_CD] = NULLIF([INVENTSTATUSID], '')
			,[Counting_Reason] = CASE COUNTINGREASONCODE
				WHEN 'WD'
					THEN 'Warehouse Damage'
				WHEN 'RD'
					THEN 'Inbound Damage'
				WHEN 'LW'
					THEN 'Lost in Warehouse'
				WHEN 'LC'
					THEN 'Lost Cycle Count'
				WHEN 'PA'
					THEN 'Process Adjustment'
				WHEN 'RT'
					THEN 'Receipt Damage'
				WHEN 'RQ'
					THEN 'Receipt Discrepancy'
				WHEN 'XD'
					THEN 'Return Discard/Destroy'
				WHEN 'XA'
					THEN 'Returns Discrepancy'
				WHEN 'MB'
					THEN 'Make Set/Break Set'
				ELSE COUNTINGREASONCODE
				END
			,[Inventory_Status] = CASE [INVENTSTATUSID]
				WHEN 'AV'
					THEN 'Available'
				WHEN 'BL'
					THEN 'Hold (Blocking)'
				WHEN 'DM'
					THEN 'Damaged (Unknown Source)'
				WHEN 'WD'
					THEN 'Damaged (Warehouse)'
				WHEN 'ID'
					THEN 'Damaged (Inbound)'
				WHEN 'RH'
					THEN 'Hold (Receipt)'
				WHEN 'RT'
					THEN 'Returns Sort'
				WHEN 'GQ'
					THEN 'Hold (Quality)'
				WHEN 'DE'
					THEN 'Damaged (Destroy)'
				WHEN 'QH'
					THEN 'Hold (Quality)'
				WHEN 'LQ'
					THEN 'Liquidate'
				ELSE NULLIF([INVENTSTATUSID], '')
				END
			,[is_Removed_From_Source] = CAST(0 AS BIT)
			,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Count] = CAST(1 AS TINYINT)
		FROM [Entity_Staging].[dbo].[rsmWMSInventoryJournalStaging]
		)
		,tgt
	AS (
		SELECT *
		FROM [CWC_DW].[Dimension].[Inventory_Journal_Properties]
		)
	MERGE INTO tgt
	USING src
		ON tgt.[Counting_Reason_CD] = src.[Counting_Reason_CD]
			AND ISNULL(tgt.[Inventory_Status_CD], '') = ISNULL(src.[Inventory_Status_CD], '')
	WHEN NOT MATCHED
		THEN
			INSERT (
				[Counting_Reason_CD]
				,[Inventory_Status_CD]
				,[Counting_Reason]
				,[Inventory_Status]
				,[is_Removed_From_Source]
				,[ETL_Created_Date]
				,[ETL_Modified_Date]
				,[ETL_Modified_Count]
				)
			VALUES (
				src.[Counting_Reason_CD]
				,src.[Inventory_Status_CD]
				,src.[Counting_Reason]
				,src.[Inventory_Status]
				,src.[is_Removed_From_Source]
				,src.[ETL_Created_Date]
				,src.[ETL_Modified_Date]
				,src.[ETL_Modified_Count]
				)
	WHEN MATCHED
		AND ISNULL(tgt.[Counting_Reason], '') <> ISNULL(src.[Counting_Reason], '')
		OR ISNULL(tgt.[Inventory_Status], '') <> ISNULL(src.[Inventory_Status], '')
		OR ISNULL(tgt.[is_Removed_From_Source], '') <> ISNULL(src.[is_Removed_From_Source], '')
		THEN
			UPDATE
			SET [Counting_Reason] = src.[Counting_Reason]
				,[Inventory_Status] = src.[Inventory_Status]
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