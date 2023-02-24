CREATE PROC [Import].[usp_Fact_Sales_Invoice_Key_Update]

AS

WITH Invoice_Seq AS
(
	SELECT 
		 [Sales_Key] = s.Sales_Key
		,[Invoice_Key] = i.Invoice_Key
		,Seq = ROW_NUMBER() OVER(PARTITION BY i.Sales_Key ORDER BY i.[Invoice_Line_Date] ASC,i.Invoice_Key ASC)
	FROM [CWC_DW].[Fact].[Sales] (NOLOCK) s
		LEFT JOIN [CWC_DW].[fact].[Invoices] i ON i.Sales_Key = s.Sales_Key
	WHERE i.is_Removed_From_Source = 0 AND s.is_Removed_From_Source = 0 --AND s.Sales_Key = 12823389
)
,Invoice_Sales AS
(
	SELECT
		 Sales_Key
		,Invoice_Key
	FROM Invoice_Seq
	WHERE Seq = 1
) --SELECT * FROM Invoice_Sales

 UPDATE s
 SET s.[Invoice_Key] = i.Invoice_Key
--SELECT s.Sales_Key,s.Sales_Line_Number,s.Invoice_Key,i.Sales_Key,i.Invoice_Key
 FROM [CWC_DW].[Fact].[Sales] (NOLOCK) s
	 LEFT JOIN Invoice_Seq i ON i.Sales_Key = s.Sales_Key
 WHERE ISNULL(i.Invoice_Key,'') <> ISNULL(s.Invoice_Key,'');


