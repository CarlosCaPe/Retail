

CREATE PROC [Import].[usp_Fact_Sales_Sales_Order_Fill_Key_Update]

AS


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

BEGIN TRY

		;WITH Invoices AS
		(
			SELECT s.Sales_Key
				  ,Invoice_Amount = SUM(i.Invoice_Line_Amount)
				  ,Invoice_Quantity = SUM(i.Invoice_Line_Quantity)
				  ,Invoice_Date = MAX(i.Invoice_Line_Date)
				  ,Fill_CD = CASE 
									WHEN ISNULL(SUM(s.[Sales_Line_Ordered_Quantity]),0) <= SUM(i.Invoice_Line_Quantity) THEN 2 --Complete Fill
									WHEN ISNULL(SUM(s.[Sales_Line_Ordered_Quantity]),0) > SUM(i.Invoice_Line_Quantity) THEN 1 --Partial Fill 
				  ELSE 0 END -- No Fill
			FROM [CWC_DW].[Fact].[Sales]   s
			INNER JOIN [CWC_DW].[Fact].[Invoices]   i ON i.Sales_Key = s.Sales_Key
			INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes]   soa ON s.Sales_Order_Attribute_Key = soa.[Sales_Order_Attribute_Key]
			WHERE soa.[Order_Classification] = 'Sale' 
			GROUP BY s.Sales_Key

		)
		,Sales AS
		(
		SELECT 
			 [Sales_Key] = s.[Sales_Key]
			 ,[Sales_Line_Created_Date] = CAST([Sales_Line_Created_Date] AS DATE)
			,[Invoice_Date] = i.Invoice_Date
			,[Fill_CD] = ISNULL(Fill_CD,0)
			,[Order_Classification]
			,[Days_To_Fill] = 
				CASE 
					WHEN Fill_CD = 2 AND [Order_Classification] = 'Sale' AND DATEDIFF(DAY,CAST([Sales_Line_Created_Date] AS DATE),i.[Invoice_Date]) > 0 THEN DATEDIFF(DAY,CAST([Sales_Line_Created_Date] AS DATE),i.[Invoice_Date])
					WHEN Fill_CD = 2 AND [Order_Classification] = 'Sale' THEN 0
					WHEN Fill_CD = 1 AND [Order_Classification] = 'Sale' THEN DATEDIFF(DAY,CAST([Sales_Line_Created_Date] AS DATE),CAST(GETDATE() AS DATE))
					WHEN ISNULL(Fill_CD,0) = 0 THEN DATEDIFF(DAY,CAST([Sales_Line_Created_Date] AS DATE),CAST(GETDATE() AS DATE))
		
				END
		FROM [CWC_DW].[Fact].[Sales]   s
		LEFT JOIN Invoices i ON s.Sales_Key = i.Sales_Key
		INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes]   soa ON s.Sales_Order_Attribute_Key = soa.[Sales_Order_Attribute_Key]
		WHERE soa.[Order_Classification] = 'Sale' --AND Fill_CD IS NULL
		) 

		UPDATE s
		SET s.Sales_Order_Fill_Key = sof.Sales_Order_Fill_Key
		FROM [CWC_DW].[Fact].[Sales] s
		INNER JOIN Sales ON sales.Sales_Key = s.Sales_Key
		LEFT JOIN [CWC_DW].[Dimension].[Sales_Order_Fill]   sof ON Sales.Fill_CD = sof.Fill_CD AND Sales.Days_To_Fill BETWEEN sof.Range_Start AND ISNULL(sof.Range_Stop,Sales.Days_To_Fill)
		WHERE ISNULL(s.Sales_Order_Fill_Key,0) <> ISNULL(sof.Sales_Order_Fill_Key,0);
END TRY

BEGIN CATCH

	DECLARE @InputParameters NVARCHAR(MAX)
	If @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT @InputParameters = '';
	EXEC Administration.usp_ErrorLogger_Insert @InputParameters;

END CATCH
