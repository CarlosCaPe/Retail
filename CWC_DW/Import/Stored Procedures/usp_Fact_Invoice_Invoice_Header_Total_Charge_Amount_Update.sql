
CREATE PROC [Import].[usp_Fact_Invoice_Invoice_Header_Total_Charge_Amount_Update]
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

BEGIN TRY
	DECLARE @procedureUpdateKey_ AS INT = 0
		,@USER AS VARCHAR(20) = current_user
		,@date AS SMALLDATETIME = getdate()
		,@stored_procedure_name VARCHAR(50) = OBJECT_NAME(@@PROCID);

	EXEC Administration.usp_Procedure_Updates_Insert @procedureName = @stored_procedure_name
		,@procedureUpdateKey = @procedureUpdateKey_ OUTPUT;;

	WITH src_seq
	AS (
		SELECT [Invoice_Key]
			,[Invoice_Number]
			,[Invoice_Line_Number]
			,[Invoice_Header_Total_Charge_Amount] = ih.[TOTALCHARGEAMOUNT]
			,[Seq] = ROW_NUMBER() OVER (
				PARTITION BY [Invoice_Number] ORDER BY [Invoice_Line_Number] ASC
					,[Invoice_Key] ASC
				)
		FROM [CWC_DW].[Fact].[Invoices] i
		LEFT JOIN [AX_PRODUCTION].[dbo].[ITSSalesInvoiceHeaderStaging] ih ON i.[Invoice_Number] = ih.[INVOICENUMBER]
		)
		,src
	AS (
		SELECT [Invoice_Key]
			,[Invoice_Line_Number]
			,[Invoice_Header_Total_Charge_Amount]
		FROM src_seq
		WHERE Seq = 1
		)
	UPDATE i
	SET i.[Invoice_Header_Total_Charge_Amount] = src.Invoice_Header_Total_Charge_Amount
	FROM [CWC_DW].[Fact].[Invoices] i
	LEFT JOIN src ON i.Invoice_Key = src.Invoice_Key
	WHERE (ISNULL(i.[Invoice_Header_Total_Charge_Amount], 0) <> ISNULL(src.Invoice_Header_Total_Charge_Amount, 0))
		OR (
			i.[Invoice_Header_Total_Charge_Amount] IS NULL
			AND src.Invoice_Header_Total_Charge_Amount IS NOT NULL
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
