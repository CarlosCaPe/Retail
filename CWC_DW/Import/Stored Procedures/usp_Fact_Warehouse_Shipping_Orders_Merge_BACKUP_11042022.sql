
CREATE PROC [Import].[usp_Fact_Warehouse_Shipping_Orders_Merge_BACKUP_11042022]
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
		SELECT DISTINCT s.[Sales_Key]
			,[Pick_ID] = [pickid]
			,[TP_Part_ID] = [TP_PARTID]
			,[Invent_Trans_ID] = [inventTransId]
			,[Sales_Order_Number] = [salesId]
			,[VP_ID] = [VPID]
			,[Created_Date] = CAST([createdinVP] AS DATETIME2(5))
			,[Exported_Date] = CAST([exportedToAx] AS DATETIME2(5))
			,[Pick_Quantity] = [QTY]
			,[UPC]
			,[is_Removed_From_Source] = CAST(0 AS BIT)
			,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Count] = CAST(1 AS SMALLINT)
		FROM [WMS_INV].[dbo].[EX940] p
		INNER JOIN [CWC_DW].[Fact].[Sales] s ON s.Sales_Order_Number = p.SalesID
			AND s.Invent_Trans_ID = p.inventTransId
		WHERE [pickid] = 231739740
		)
		,tgt
	AS (
		SELECT *
		FROM [CWC_DW].[Fact].[Warehouse_Shipping_Orders]
		)
	MERGE INTO tgt
	USING src
		ON tgt.Sales_Key = src.Sales_Key
			AND tgt.Pick_ID = src.Pick_ID
			AND tgt.VP_ID = src.VP_ID
	WHEN NOT MATCHED
		THEN
			INSERT (
				[Sales_Key]
				,[Pick_ID]
				,[TP_Part_ID]
				,[Invent_Trans_ID]
				,[Sales_Order_Number]
				,[VP_ID]
				,[Created_Date]
				,[Exported_Date]
				,[Pick_Quantity]
				,[UPC]
				,[is_Removed_From_Source]
				,[ETL_Created_Date]
				,[ETL_Modified_Date]
				,[ETL_Modified_Count]
				)
			VALUES (
				src.[Sales_Key]
				,src.[Pick_ID]
				,src.[TP_Part_ID]
				,src.[Invent_Trans_ID]
				,src.[Sales_Order_Number]
				,src.[VP_ID]
				,src.[Created_Date]
				,src.[Exported_Date]
				,src.[Pick_Quantity]
				,src.[UPC]
				,src.[is_Removed_From_Source]
				,src.[ETL_Created_Date]
				,src.[ETL_Modified_Date]
				,src.[ETL_Modified_Count]
				)
	WHEN MATCHED
		AND ISNULL(tgt.[TP_Part_ID], '') <> ISNULL(src.[TP_Part_ID], '')
		OR ISNULL(tgt.[Invent_Trans_ID], '') <> ISNULL(src.[Invent_Trans_ID], '')
		OR ISNULL(tgt.[Sales_Order_Number], '') <> ISNULL(src.[Sales_Order_Number], '')
		OR ISNULL(tgt.[Created_Date], '') <> ISNULL(src.[Created_Date], '')
		OR ISNULL(tgt.[Exported_Date], '') <> ISNULL(src.[Exported_Date], '')
		OR ISNULL(tgt.[Pick_Quantity], '') <> ISNULL(src.[Pick_Quantity], '')
		OR ISNULL(tgt.[UPC], '') <> ISNULL(src.[UPC], '')
		OR ISNULL(tgt.[is_Removed_From_Source], '') <> ISNULL(src.[is_Removed_From_Source], '')
		THEN
			UPDATE
			SET [TP_Part_ID] = src.[TP_Part_ID]
				,[Invent_Trans_ID] = src.[Invent_Trans_ID]
				,[Sales_Order_Number] = src.[Sales_Order_Number]
				,[VP_ID] = src.[VP_ID]
				,[Created_Date] = src.[Created_Date]
				,[Exported_Date] = src.[Exported_Date]
				,[Pick_Quantity] = src.[Pick_Quantity]
				,[UPC] = src.[UPC]
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
