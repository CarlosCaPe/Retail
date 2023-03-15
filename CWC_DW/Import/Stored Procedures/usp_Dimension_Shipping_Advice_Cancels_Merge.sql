
CREATE PROC [Import].[usp_Dimension_Shipping_Advice_Cancels_Merge]
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
		SELECT [is_Canceled] = CASE 
				WHEN NULLIF([cancelReason], '') IS NULL
					THEN 0
				ELSE 1
				END
			,[Cancel] = CASE 
				WHEN NULLIF([cancelReason], '') IS NULL
					THEN 'Not Canceled'
				ELSE 'Canceled'
				END
			,[Cancel_Reason_CD] = NULLIF([cancelReason], '')
			,[Cancel_Reason] = NULLIF([cancelReason], '')
			,[is_Removed_From_Source] = CAST(0 AS BIT)
			,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Count] = CAST(1 AS SMALLINT)
		FROM [WMS_INV].[dbo].[EX945] w
		INNER JOIN [CWC_DW].[Fact].[Sales] s ON s.Sales_Order_Number = w.SalesID
			AND s.Invent_Trans_ID = w.inventTransId
		GROUP BY NULLIF([cancelReason], '')
		)
		,tgt
	AS (
		SELECT *
		FROM [CWC_DW].[Dimension].[Shipping_Advice_Cancels]
		)
	MERGE INTO tgt
	USING src
		ON tgt.[is_Canceled] = src.[is_Canceled]
			AND ISNULL(tgt.[Cancel_Reason_CD], '') = ISNULL(src.[Cancel_Reason_CD], '')
	WHEN NOT MATCHED
		THEN
			INSERT (
				[is_Canceled]
				,[Cancel_Reason_CD]
				,[Cancel]
				,[Cancel_Reason]
				,[is_Removed_From_Source]
				,[ETL_Created_Date]
				,[ETL_Modified_Date]
				,[ETL_Modified_Count]
				)
			VALUES (
				src.[is_Canceled]
				,src.[Cancel_Reason_CD]
				,src.[Cancel]
				,src.[Cancel_Reason]
				,src.[is_Removed_From_Source]
				,src.[ETL_Created_Date]
				,src.[ETL_Modified_Date]
				,src.[ETL_Modified_Count]
				)
	WHEN MATCHED
		AND ISNULL(tgt.[Cancel], '') <> ISNULL(src.[Cancel], '')
		OR ISNULL(tgt.[is_Removed_From_Source], '') <> ISNULL(src.[is_Removed_From_Source], '')
		THEN
			UPDATE
			SET [Cancel] = src.[Cancel]
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