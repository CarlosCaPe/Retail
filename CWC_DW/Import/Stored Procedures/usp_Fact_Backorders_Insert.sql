
CREATE PROC [Import].[usp_Fact_Backorders_Insert]

AS

DECLARE @Snapshot_Date_Key INT;

SELECT @Snapshot_Date_Key = Date_Key
FROM [CWC_DW].[Dimension].[Dates] (NOLOCK) d
WHERE Calendar_Date = CAST(GETDATE() -1 AS DATE);

DELETE [CWC_DW].[Fact].[Backorders] WHERE Snapshot_Date_Key = @Snapshot_Date_Key;

INSERT INTO CWC_DW.Fact.Backorders

SELECT
	 Snapshot_Date_Key = @Snapshot_Date_Key
	,s.*
--INTO CWC_DW.Fact.Backorders
FROM [CWC_DW].[Fact].[Sales] (NOLOCK) s  
	INNER JOIN [CWC_DW].[Dimension].[Sales_Line_Properties] (NOLOCK) slp ON s.Sales_Line_Property_Key = slp.Sales_Line_Property_Key
	INNER JOIN [CWC_DW].[Dimension].[Sales_Header_Properties] (NOLOCK) shp ON s.Sales_Header_Property_Key = shp.Sales_Header_Property_Key
	INNER JOIN [CWC_DW].[Dimension].[Inventory_Warehouses] (NOLOCK) iw ON s.Shipping_Inventory_Warehouse_Key = iw.Inventory_Warehouse_Key
	INNER JOIN [CWC_DW].[Dimension].[Dates] (NOLOCK) d ON CAST(s.[Sales_Line_Created_Date] AS DATE) = d.Calendar_Date
WHERE 
		slp.Sales_Line_Status = 'Backorder'
	AND ISNULL([Sales_Line_Ordered_Sales_Quantity],0) > 0
	AND ISNULL([Sales_Line_Reserve_Quantity],0) = 0
	AND CAST([Sales_Line_Created_Date] AS DATE) >= '12/1/2020'
	AND iw.Inventory_Warehouse IN (/*'Distribution Center',*/'XB') -- Removed GEODIS orders per conversation with Brian 2/15/2023
	AND shp.Sales_Header_Status <> 'Canceled'
	AND s.is_Removed_From_Source = 0;

UPDATE [CWC_DW].[Dimension].[Dates]
SET [is_Current_Backorder_Date] = CASE WHEN Date_Key = @Snapshot_Date_Key THEN 1 ELSE 0 END;


-- Flag BO orders on pick
WITH Picks AS
(
SELECT  Sales_Key,Created_Date = CAST(Created_Date AS DATE)
FROM [CWC_DW].[Fact].[Warehouse_Shipping_Orders] (NOLOCK)
--WHERE is_Removed_From_Source = 0
)

UPDATE b
SET is_Excluded = CASE WHEN p.Sales_Key IS NULL THEN 0 ELSE 1 END
--SELECT COUNT(*)
FROM [CWC_DW].[Fact].[Backorders] b (NOLOCK)
INNER JOIN [CWC_DW].[Dimension].[Dates] (NOLOCK) d ON b.Snapshot_Date_Key = d.Date_Key
LEFT JOIN Picks p ON p.Sales_Key = b.Sales_Key AND d.Calendar_Date > p.Created_Date
WHERE b.is_Excluded <> CASE WHEN p.Sales_Key IS NULL THEN 0 ELSE 1 END;