CREATE PROC [Import].[usp_Fact_Invoice_Invoice_Header_Total_Charge_Amount_Update] AS

SET NOCOUNT ON;

;WITH src_seq AS
	(
		SELECT
			 [Invoice_Key]
			,[Invoice_Number]
			,[Invoice_Line_Number]
			,[Invoice_Header_Total_Charge_Amount] = ih.[TOTALCHARGEAMOUNT]
			,[Seq] = ROW_NUMBER() OVER(PARTITION BY [Invoice_Number] ORDER BY [Invoice_Line_Number] ASC,[Invoice_Key] ASC)
		FROM [CWC_DW].[Fact].[Invoices] (NOLOCK) i
		LEFT JOIN [AX_PRODUCTION].[dbo].[ITSSalesInvoiceHeaderStaging] (NOLOCK) ih  ON i.[Invoice_Number] = ih.[INVOICENUMBER]
	)
,src AS
	(
		SELECT
			 [Invoice_Key]
			,[Invoice_Line_Number]
			,[Invoice_Header_Total_Charge_Amount]
		FROM src_seq
		WHERE Seq = 1
	)--SELECT COUNT(*) FROM src

UPDATE i
SET i.[Invoice_Header_Total_Charge_Amount] = src.Invoice_Header_Total_Charge_Amount
FROM [CWC_DW].[Fact].[Invoices] i
	LEFT JOIN src ON i.Invoice_Key = src.Invoice_Key
WHERE (ISNULL(i.[Invoice_Header_Total_Charge_Amount],0) <> ISNULL(src.Invoice_Header_Total_Charge_Amount,0))
	OR (i.[Invoice_Header_Total_Charge_Amount] IS NULL AND src.Invoice_Header_Total_Charge_Amount IS NOT NULL);
