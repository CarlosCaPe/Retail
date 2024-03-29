﻿
CREATE PROC [Import].[usp_Fact_Vendor_Packing_Slip_Merge]
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

	WITH Packing_Slips
	AS (
		SELECT [Vendor_Packing_Slip_ID] = [PACKINGSLIPID]
			,[Vendor_Account_Number] = [ORDERACCOUNT]
			,[Invent_Trans_ID] = [INVENTTRANSID]
			,[Purchase_Order_Number] = [PURCHID]
			,[Vendor_Packing_Slip_Quantity] = [QTY]
			,[Vendor_Packing_Trans_Rec_ID] = [VENDPACKINGTRANSRECID]
			,[Vendor_Packing_Accounting_Date] = CAST([ACCOUNTINGDATE] AS DATE)
		FROM [AX_PRODUCTION].[dbo].[ITSVendPackingSlipStaging]
		)
		,src
	AS (
		SELECT ps.[Vendor_Packing_Slip_ID]
			,ps.[Invent_Trans_ID]
			,ps.[Vendor_Account_Number]
			,ps.[Purchase_Order_Number]
			,po.[Purchase_Order_Key]
			,po.[Vendor_Key]
			,po.[Product_Key]
			,po.[Delivery_Location_Key]
			,po.[Purchase_Order_Line_Number]
			,po.[Purchase_Order_Name]
			,po.[Purchase_Line_Description]
			,ps.[Vendor_Packing_Slip_Quantity]
			,ps.[Vendor_Packing_Trans_Rec_ID]
			,ps.[Vendor_Packing_Accounting_Date]
			,[is_Backordered_Product] = 0
			,[is_Removed_From_Source] = CAST(0 AS BIT)
			,[is_Excluded] = CAST(0 AS BIT)
			,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Count] = CAST(1 AS TINYINT)
		FROM [CWC_DW].[Fact].[Purchase_Orders] po
		INNER JOIN Packing_Slips ps ON ps.Purchase_Order_Number = po.[Purchase_Order_Number]
			AND ps.[Invent_Trans_ID] = po.[Invent_Trans_ID]
		)
		,tgt
	AS (
		SELECT *
		FROM [CWC_DW].[Fact].[Vendor_Packing_Slips]
		)
	MERGE INTO tgt
	USING src
		ON tgt.[Vendor_Packing_Slip_ID] = src.[Vendor_Packing_Slip_ID]
			AND tgt.[Invent_Trans_ID] = src.[Invent_Trans_ID]
	WHEN NOT MATCHED
		THEN
			INSERT (
				[Vendor_Packing_Slip_ID]
				,[Invent_Trans_ID]
				,[Vendor_Account_Number]
				,[Purchase_Order_Number]
				,[Purchase_Order_Key]
				,[Vendor_Key]
				,[Product_Key]
				,[Delivery_Location_Key]
				,[Purchase_Order_Line_Number]
				,[Purchase_Order_Name]
				,[Purchase_Line_Description]
				,[Vendor_Packing_Slip_Quantity]
				,[Vendor_Packing_Trans_Rec_ID]
				,[Vendor_Packing_Accounting_Date]
				,[is_Backordered_Product]
				,[is_Removed_From_Source]
				,[is_Excluded]
				,[ETL_Created_Date]
				,[ETL_Modified_Date]
				,[ETL_Modified_Count]
				)
			VALUES (
				src.[Vendor_Packing_Slip_ID]
				,src.[Invent_Trans_ID]
				,src.[Vendor_Account_Number]
				,src.[Purchase_Order_Number]
				,src.[Purchase_Order_Key]
				,src.[Vendor_Key]
				,src.[Product_Key]
				,src.[Delivery_Location_Key]
				,src.[Purchase_Order_Line_Number]
				,src.[Purchase_Order_Name]
				,src.[Purchase_Line_Description]
				,src.[Vendor_Packing_Slip_Quantity]
				,src.[Vendor_Packing_Trans_Rec_ID]
				,src.[Vendor_Packing_Accounting_Date]
				,src.[is_Backordered_Product]
				,src.[is_Removed_From_Source]
				,src.[is_Excluded]
				,src.[ETL_Created_Date]
				,src.[ETL_Modified_Date]
				,src.[ETL_Modified_Count]
				)
	WHEN MATCHED
		AND ISNULL(tgt.[Vendor_Account_Number], '') <> ISNULL(src.[Vendor_Account_Number], '')
		OR ISNULL(tgt.[Purchase_Order_Number], '') <> ISNULL(src.[Purchase_Order_Number], '')
		OR ISNULL(tgt.[Purchase_Order_Key], '') <> ISNULL(src.[Purchase_Order_Key], '')
		OR ISNULL(tgt.[Vendor_Key], '') <> ISNULL(src.[Vendor_Key], '')
		OR ISNULL(tgt.[Product_Key], '') <> ISNULL(src.[Product_Key], '')
		OR ISNULL(tgt.[Delivery_Location_Key], '') <> ISNULL(src.[Delivery_Location_Key], '')
		OR ISNULL(tgt.[Purchase_Order_Line_Number], '') <> ISNULL(src.[Purchase_Order_Line_Number], '')
		OR ISNULL(tgt.[Purchase_Order_Name], '') <> ISNULL(src.[Purchase_Order_Name], '')
		OR ISNULL(tgt.[Purchase_Line_Description], '') <> ISNULL(src.[Purchase_Line_Description], '')
		OR ISNULL(tgt.[Vendor_Packing_Slip_Quantity], '') <> ISNULL(src.[Vendor_Packing_Slip_Quantity], '')
		OR ISNULL(tgt.[Vendor_Packing_Trans_Rec_ID], '') <> ISNULL(src.[Vendor_Packing_Trans_Rec_ID], '')
		OR ISNULL(tgt.[Vendor_Packing_Accounting_Date], '') <> ISNULL(src.[Vendor_Packing_Accounting_Date], '')
		OR ISNULL(tgt.[is_Removed_From_Source], '') <> ISNULL(src.[is_Removed_From_Source], '')
		THEN
			UPDATE
			SET [Vendor_Account_Number] = src.[Vendor_Account_Number]
				,[Purchase_Order_Number] = src.[Purchase_Order_Number]
				,[Purchase_Order_Key] = src.[Purchase_Order_Key]
				,[Vendor_Key] = src.[Vendor_Key]
				,[Product_Key] = src.[Product_Key]
				,[Delivery_Location_Key] = src.[Delivery_Location_Key]
				,[Purchase_Order_Line_Number] = src.[Purchase_Order_Line_Number]
				,[Purchase_Order_Name] = src.[Purchase_Order_Name]
				,[Purchase_Line_Description] = src.[Purchase_Line_Description]
				,[Vendor_Packing_Slip_Quantity] = src.[Vendor_Packing_Slip_Quantity]
				,[Vendor_Packing_Trans_Rec_ID] = src.[Vendor_Packing_Trans_Rec_ID]
				,[Vendor_Packing_Accounting_Date] = src.[Vendor_Packing_Accounting_Date]
				,[is_Backordered_Product] = src.[is_Backordered_Product]
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
