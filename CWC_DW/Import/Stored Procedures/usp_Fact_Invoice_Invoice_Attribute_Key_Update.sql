

CREATE PROC [Import].[usp_Fact_Invoice_Invoice_Attribute_Key_Update]

AS

SET NOCOUNT ON;

WITH Snapshot_Products AS
	(
		SELECT 
		DISTINCT Sales_Key,Product_Key = Sales_Line_Product_Key
		FROM [CWC_DW].[Fact].[Backorders] (NOLOCK) b
	)
,Backorder_Invoices AS
	(
		SELECT i.Invoice_Key,is_Backorder_Fill = CASE WHEN sp.Sales_Key IS NOT NULL THEN 1 ELSE 0 END
		FROM [CWC_DW].[Fact].[Invoices] (NOLOCK) i
		--INNER JOIN [CWC_DW].[Dimension].[Dates] d ON d.Calendar_Date = DATEADD(DAY,-3,i.Invoice_Line_Date)
		INNER JOIN Snapshot_Products sp ON   i.Sales_Key = sp.Sales_Key AND i.Invoice_Line_Product_Key = sp.Product_Key AND LEFT(Invoice_Number,3) = 'INV'
	) --SELECT TOP 10000 * FROM Backorder_Invoices
,Free_Shipping AS
	(
		SELECT Invoice_Number,is_Free_Shipping = CASE WHEN ISNULL(SUM(i.[Invoice_Header_Total_Charge_Amount]),0) > 0 THEN 0 ELSE 1 END
		FROM [CWC_DW].[Fact].[Invoices] (NOLOCK) i
		GROUP BY Invoice_Number
	)

UPDATE i
SET i.Invoice_Attribute_Key = ia.Invoice_Attribute_Key
--SELECT TOP 1000 i.*
FROM [CWC_DW].[Fact].[Invoices] (NOLOCK) i
	LEFT JOIN Backorder_Invoices b ON i.Invoice_Key = b.Invoice_Key
	LEFT JOIN Free_Shipping f ON i.Invoice_Number = f.Invoice_Number
	LEFT JOIN [CWC_DW].[Dimension].[Invoice_Attributes] (NOLOCK) ia ON ISNULL(b.is_Backorder_Fill,0) = ia.is_Backorder_Fill 
																   AND ISNULL((CASE WHEN DATEDIFF(DAY,i.Invoice_Line_Date,GETDATE()) > 90 THEN 1 ELSE 0 END),0) =ia.is_Baked
																   AND f.is_Free_Shipping = ia.is_Free_Shipping
WHERE ISNULL(i.Invoice_Attribute_Key,0) <> ia.Invoice_Attribute_Key;
