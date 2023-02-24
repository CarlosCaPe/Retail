


CREATE VIEW [Analytics].[v_Fact_Backorder_Snapshots] AS
--/*		
WITH BO AS
(
SELECT --TOP 10
	 [Backorder_Date_Key] = sd.Date_Key
	,[Backorder_Amount] = SUM((b.[Sales_Line_Amount]/b.[Sales_Line_Ordered_Sales_Quantity]) * b.[Sales_Line_Remain_Sales_Physical])
	,[Backorder_Units] = SUM(b.[Sales_Line_Remain_Sales_Physical]) --b.Sales_Line_Ordered_Sales_Quantity
FROM [CWC_DW].[Fact].[Backorders] (NOLOCK) b
	INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) sd ON b.[Snapshot_Date_Key] = sd.[Date_Key]
	--INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) bd ON CAST(b.[Sales_Line_Created_Date] AS DATE) = bd.[Calendar_Date]
	INNER JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON b.Sales_Line_Product_Key = p.Product_Key
	INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes] (NOLOCK) soa ON b.Sales_Order_Attribute_Key = soa.Sales_Order_Attribute_Key
	--LEFT JOIN [CWC_DW].[Dimension].[Sales_Header_Properties] shp ON shp.[Sales_Header_Property_Key] = b.[Sales_Header_Property_Key]
	--LEFT JOIN [CWC_DW].[Dimension].[Locations] l ON b.[Sales_Header_Location_Key] = l.[Location_Key]
	--LEFT JOIN [CWC_DW].[Fact].[Trade_Agreement_Prices] tp ON b.Sales_Line_Product_Key = tp.Product_Key AND CAST(b.Sales_Line_Created_Date_EST AS DATE) BETWEEN tp.[Start_Date] AND tp.[End_Date] AND tp.is_Removed_From_Source = 0
--WHERE sd.Current_Backorder_Date = 'Current Backorder Date'
GROUP BY
	sd.Date_Key
)
		SELECT
		 [Backorder Date] = d.Calendar_Date
		,[Backorder Amount] = [Backorder_Amount]
		,[Backorder Units] = [Backorder_Units]
		,[Backorder New Quantity] = ds.[Units_Backorder]
		--,[Backorder New Orders] = [Orders_Backorder]
		,[Backorder New Amount] = ds.Amount_Backorder
		,[Backorder New Orders] = ds.Orders_Backorder
		,[Backorder Shipped Amount] = ds.Backorder_Shipped_Amount
		,[Backorder Shipped Quantity] = ds.Backorder_Shipped_Quantity
		,[Backorder Cancel Amount] = ds.[Backorder_Canceled_Amount]
		,[Backorder Cancel Units] = ds.[Backorder_Canceled_Quantity]	
		--INTO Fact.Backorder_Summary
		FROM BO
		INNER JOIN CWC_DW.Dimension.Dates d ON BO.Backorder_Date_Key = d.Date_Key
		LEFT JOIN [CWC_DW].[Fact].[Demand_Summary] ds ON BO.[Backorder_Date_Key] = ds.Date_Key
		

		--,b.Sales_Line_Product_Key
		--,CASE soa.On_Pick_List WHEN 'On Pick List' THEN 1 ELSE 0 END
		;

--*/
		--SELECT
		-- [Backorder Date]-- = d.Calendar_Date
		--,[Backorder Amount]-- = [Backorder_Amount]
		--,[Backorder Units]-- = [Backorder_Units]
		--,[Backorder New Quantity]-- = [Units_Backorder]
		----,[Backorder New Orders] = [Orders_Backorder]
		--,[Backorder New Amount] --= ds.Amount_Backorder
		--,[Backorder Shipped Amount]-- = ds.Backorder_Shipped_Amount
		--,[Backorder Shipped Quantity]-- = ds.Backorder_Shipped_Quantity
		--,[Backorder Cancel Amount]-- = ds.[Backorder_Canceled_Amount]
		--,[Backorder Cancel Units]-- = ds.[Backorder_Canceled_Quantity]	
		----INTO Fact.Backorder_Summary
		--FROM Fact.Backorder_Summary
