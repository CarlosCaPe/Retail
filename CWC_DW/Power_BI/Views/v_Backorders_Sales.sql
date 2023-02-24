


CREATE VIEW [Power_BI].[v_Backorders_Sales]

AS

SELECT
	 [Sales Order Number] = b.Sales_Order_Number
	,[Product Key] = b.Sales_Line_Product_Key
	,[Sales Line Number] = b.Sales_Line_Number
	,[Sales Line Created Date] = CAST(DATEADD(hh,-5,b.[Sales_Line_Created_Date]) AS DATE)
	,[Sales Header Status] = CASE shp.Sales_Header_Status WHEN 'Backorder' THEN 'Open' ELSE shp.Sales_Header_Status END
	,[Sales Line Status] = CASE slp.Sales_Line_Status WHEN 'Backorder' THEN 'Open' ELSE slp.Sales_Line_Status END
	,[Sales Line Type] = slp.Sales_Line_Type
	,[Sales Line Quantity] = b.[Sales_Line_Remain_Sales_Physical]
	,[Backorder Amount] = ((b.[Sales_Line_Amount]/b.[Sales_Line_Ordered_Sales_Quantity]) * b.[Sales_Line_Remain_Sales_Physical])
	,[On Pick List] = CASE soa.On_Pick_List WHEN 'Not On Pick List' THEN 'No' ELSE 'Yes' END
--SELECT COUNT(*)
FROM [CWC_DW].[Fact].[Backorders] (NOLOCK) b
	INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) sd ON b.[Snapshot_Date_Key] = sd.[Date_Key]
	INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) bd ON CAST(b.[Sales_Line_Created_Date] AS DATE) = bd.[Calendar_Date]
	INNER JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON b.Sales_Line_Product_Key = p.Product_Key
	LEFT JOIN [CWC_DW].[Fact].[Purchase_Orders] (NOLOCK) po ON p.Earliest_Open_Purchase_Order_Key = po.Purchase_Order_Key
	INNER JOIN [CWC_DW].[Dimension].[Sales_Line_Properties] (NOLOCK) slp ON b.Sales_Line_Property_Key = slp.Sales_Line_Property_Key
	INNER JOIN [CWC_DW].[Dimension].[Sales_Header_Properties] (NOLOCK) shp ON b.Sales_Header_Property_Key = shp.Sales_Header_Property_Key
	INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes] (NOLOCK) soa ON b.Sales_Order_Attribute_Key = soa.Sales_Order_Attribute_Key
WHERE sd.Current_Backorder_Date = 'Current Backorder Date'
AND b.is_Removed_From_Source = 0;

