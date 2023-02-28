
CREATE PROC [Import].[usp_Fact_Sales_Invoice_Key_Update]

AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

BEGIN TRY


		WITH Invoice_Seq AS
		(
			SELECT 
				 [Sales_Key] = s.Sales_Key
				,[Invoice_Key] = i.Invoice_Key
				,Seq = ROW_NUMBER() OVER(PARTITION BY i.Sales_Key ORDER BY i.[Invoice_Line_Date] ASC,i.Invoice_Key ASC)
			FROM [CWC_DW].[Fact].[Sales]   s
				LEFT JOIN [CWC_DW].[fact].[Invoices] i ON i.Sales_Key = s.Sales_Key
			WHERE i.is_Removed_From_Source = 0 AND s.is_Removed_From_Source = 0 
		)
		,Invoice_Sales AS
		(
			SELECT
				 Sales_Key
				,Invoice_Key
			FROM Invoice_Seq
			WHERE Seq = 1
		) 

		 UPDATE s
		 SET s.[Invoice_Key] = i.Invoice_Key
		 FROM [CWC_DW].[Fact].[Sales]   s
			 LEFT JOIN Invoice_Seq i ON i.Sales_Key = s.Sales_Key
		 WHERE ISNULL(i.Invoice_Key,'') <> ISNULL(s.Invoice_Key,'');

		 END TRY

BEGIN CATCH

	DECLARE @InputParameters NVARCHAR(MAX)
	If @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT @InputParameters = '';
	EXEC Administration.usp_ErrorLogger_Insert @InputParameters;

END CATCH


