
CREATE PROC [Import].[usp_Marketing_Ship_Confirmation_Carriers_Merge]
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
		SELECT DISTINCT Ship_Via = [SHIPVIA]
			,Ship_Carrier = CASE 
				WHEN LEFT(NULLIF([SHIPVIA], ''), 3) = 'UPS'
					THEN 'UPS'
				WHEN LEFT(NULLIF([SHIPVIA], ''), 4) = 'USPS'
					THEN 'USPS'
				WHEN LEFT(NULLIF([SHIPVIA], ''), 3) = 'Fed'
					THEN 'FedEx'
				WHEN LEFT(NULLIF([SHIPVIA], ''), 3) = 'DHL'
					THEN 'DHL'
				ELSE NULLIF([SHIPVIA], '')
				END
			,[is_Removed_From_Source] = CAST(0 AS BIT)
			,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Count] = CAST(1 AS TINYINT)
		FROM [Entity_Staging].[dbo].[rsmShipConfirmationStaging] ship
		WHERE NULLIF([SHIPVIA], '') IS NOT NULL
		)
		,tgt
	AS (
		SELECT *
		FROM [CWC_DW].[Marketing].[Ship_Confirmation_Carriers]
		)
	MERGE INTO tgt
	USING src
		ON tgt.Ship_Via = src.Ship_Via
	WHEN NOT MATCHED
		THEN
			INSERT (
				[Ship_Via]
				,[Ship_Carrier]
				,[is_Removed_From_Source]
				,[ETL_Created_Date]
				,[ETL_Modified_Date]
				,[ETL_Modified_Count]
				)
			VALUES (
				src.[Ship_Via]
				,src.[Ship_Carrier]
				,src.[is_Removed_From_Source]
				,src.[ETL_Created_Date]
				,src.[ETL_Modified_Date]
				,src.[ETL_Modified_Count]
				)
	WHEN MATCHED
		AND tgt.[Ship_Carrier] <> src.[Ship_Carrier]
		OR tgt.[is_Removed_From_Source] <> src.[is_Removed_From_Source]
		THEN
			UPDATE
			SET [Ship_Carrier] = src.[Ship_Carrier]
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

