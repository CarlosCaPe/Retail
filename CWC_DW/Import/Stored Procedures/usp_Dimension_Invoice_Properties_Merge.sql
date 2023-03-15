
CREATE PROC [Import].[usp_Dimension_Invoice_Properties_Merge]
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
		SELECT DISTINCT [Payment_Term] = CASE ih.[PAYMENTTERMSNAME]
				WHEN 'CreditCard'
					THEN 'Credit Card'
				WHEN 'N00'
					THEN 'Due on Receipt'
				WHEN 'N30'
					THEN 'Net 30'
				WHEN 'N60'
					THEN 'Net 60'
				WHEN 'N90'
					THEN 'Net 90'
				END
			,[Invoice_Line_Unit] = CASE il.[SALESUNITSYMBOL]
				WHEN 'ea'
					THEN 'Each'
				WHEN ''
					THEN NULL
				WHEN 'dz'
					THEN 'Dozen'
				END
			,[Invoice_Header_Delivery_Mode] = CAST(CASE ih.[DELIVERYMODECODE]
					WHEN 'STANDARD'
						THEN 'Standard Ground'
					WHEN '2Day'
						THEN '2-Day Air'
					WHEN ''
						THEN NULL
					WHEN 'OVERNT'
						THEN 'FedEx Overnight'
					WHEN 'Pickup'
						THEN 'Pickup'
					WHEN 'TUSI'
						THEN 'US Indiana Truck'
					WHEN 'ACNX'
						THEN 'India Chennai Air'
					ELSE ih.[DELIVERYMODECODE]
					END AS VARCHAR(50))
			,[is_Removed_From_Source] = CAST(0 AS BIT)
			,[is_Excluded] = CAST(0 AS BIT)
			,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Count] = CAST(1 AS TINYINT)
		--INTO CWC_DW.Dimension.Invoice_Properties
		FROM [AX_PRODUCTION].[dbo].[ITSSalesInvoiceHeaderStaging] ih
		INNER JOIN [AX_PRODUCTION].[dbo].[ITSSalesInvoiceLineStaging] il ON ih.INVOICENUMBER = il.INVOICENUMBER
		)
		,tgt
	AS (
		SELECT *
		FROM [CWC_DW].[Dimension].[Invoice_Properties]
		)
	MERGE INTO tgt
	USING src
		ON ISNULL(tgt.[Payment_Term], '') = ISNULL(src.[Payment_Term], '')
			AND ISNULL(tgt.[Invoice_Line_Unit], '') = ISNULL(src.[Invoice_Line_Unit], '')
			AND ISNULL(tgt.[Invoice_Header_Delivery_Mode], '') = ISNULL(src.[Invoice_Header_Delivery_Mode], '')
	WHEN NOT MATCHED
		THEN
			INSERT (
				[Payment_Term]
				,[Invoice_Line_Unit]
				,[Invoice_Header_Delivery_Mode]
				,[is_Removed_From_Source]
				,[is_Excluded]
				,[ETL_Created_Date]
				,[ETL_Modified_Date]
				,[ETL_Modified_Count]
				)
			VALUES (
				src.[Payment_Term]
				,src.[Invoice_Line_Unit]
				,src.[Invoice_Header_Delivery_Mode]
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