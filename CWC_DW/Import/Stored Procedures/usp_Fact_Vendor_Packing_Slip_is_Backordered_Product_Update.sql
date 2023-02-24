

CREATE PROC [Import].[usp_Fact_Vendor_Packing_Slip_is_Backordered_Product_Update]

AS

WITH Backorder_Products AS
(
SELECT DISTINCT
	   [Snapshot_Date_Key]
      ,[Sales_Line_Product_Key]
	  ,[is_Current_Backorder] = 1
FROM [CWC_DW].[Fact].[Backorders] (NOLOCK)
)

UPDATE vps
	SET is_Backordered_Product = ISNULL(bp.is_Current_Backorder,0)
FROM [CWC_DW].[Fact].[Vendor_Packing_Slips] (NOLOCK) vps
	INNER JOIN [CWC_DW].[Dimension].[Dates] (NOLOCK) d ON vps.Vendor_Packing_Accounting_Date = d.Calendar_Date
	LEFT JOIN Backorder_Products bp ON vps.[Product_Key] = bp.[Sales_Line_Product_Key] AND d.Date_Key = bp.[Snapshot_Date_Key]
WHERE ISNULL(is_Backordered_Product,0) <> ISNULL(bp.is_Current_Backorder,0);

