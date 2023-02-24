
CREATE VIEW [Power_BI].[v_Backorders_by_Style]  AS 

WITH Backorders_By_Item AS
	(
		SELECT
			 [Backorder_Amount] = SUM(([Sales_Line_Amount]/[Sales_Line_Ordered_Sales_Quantity]) * [Sales_Line_Remain_Sales_Physical])
			,[Backorder_Quantity] = SUM([Sales_Line_Remain_Sales_Physical])
			,[Backorder_Average_Unit_Retail] = SUM([Sales_Line_Amount])/SUM([Sales_Line_Ordered_Sales_Quantity])
			,[Backorder_No_Pick_List_Amount] = SUM(CASE WHEN On_Pick_List = 'Not On Pick List' THEN ([Sales_Line_Amount]/[Sales_Line_Ordered_Sales_Quantity]) * [Sales_Line_Remain_Sales_Physical] END)
			,[Backorder_No_Pick_List_Quantity] =  SUM(CASE WHEN On_Pick_List = 'Not On Pick List' THEN [Sales_Line_Remain_Sales_Physical] END)
			,[Backorder_Pick_List_Amount] = SUM(CASE WHEN On_Pick_List = 'On Pick List' THEN ([Sales_Line_Amount]/[Sales_Line_Ordered_Sales_Quantity]) * [Sales_Line_Remain_Sales_Physical] END)
			,[Backorder_Pick_List_Quantity] =  SUM(CASE WHEN On_Pick_List = 'On Pick List' THEN [Sales_Line_Remain_Sales_Physical] END)
			,[Backorder_Product_Key] = b.Sales_Line_Product_Key
		FROM [CWC_DW].[Fact].[Backorders] (NOLOCK) b
			INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) sd ON b.[Snapshot_Date_Key] = sd.[Date_Key]
			INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) bd ON CAST(b.[Sales_Line_Created_Date] AS DATE) = bd.[Calendar_Date]
			INNER JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON b.Sales_Line_Product_Key = p.Product_Key
			LEFT JOIN [CWC_DW].[Fact].[Purchase_Orders] (NOLOCK) po ON p.Earliest_Open_Purchase_Order_Key = po.Purchase_Order_Key
			INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes] (NOLOCK) soa ON b.Sales_Order_Attribute_Key = soa.Sales_Order_Attribute_Key
		WHERE sd.Current_Backorder_Date = 'Current Backorder Date'
		--AND Item_ID = '11729'
		AND b.is_Removed_From_Source = 0
		GROUP BY b.Sales_Line_Product_Key
	) --SELECT * FROM BO
--,Vendor_Packing_Slips_By_PO AS
--	(
--		SELECT Purchase_Order_Key
--			  ,Received_Quantity = SUM(CAST(ISNULL([Vendor_Packing_Slip_Quantity],0) AS INT))
--		FROM [CWC_DW].[Fact].[Vendor_Packing_Slips] (NOLOCK) vps
--		WHERE vps.is_Removed_From_Source = 0
--		GROUP BY Purchase_Order_Key
--	)
,Purchase_Order_By_Item AS
	(
		SELECT
			 po.Product_Key
			,Ordered_Quantity = SUM(po.Purchase_Line_Ordered_Quantity)
			,Received_Quantity = SUM(po.Received_Quantity)
			,Open_Quantity = SUM(po.Open_Quantity)
		FROM [CWC_DW].[Fact].[Purchase_Orders] (NOLOCK) po
			INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Purchase_Order_Properties] (NOLOCK) pop ON po.Purchase_Order_Property_Key = pop.Purchase_Order_Property_Key
			LEFT JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] ad ON po.Purchase_Order_Header_Accounting_Date = ad.Calendar_Date
			LEFT JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] cd ON po.[Purchase_Line_Confirmed_Delivery_Date] = cd.Calendar_Date
			--LEFT JOIN Vendor_Packing_Slips_By_PO vps ON po.[Purchase_Order_Key] = vps.[Purchase_Order_Key]
			LEFT JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON po.Product_Key = p.Product_Key
			INNER JOIN [CWC_DW].[Dimension].[Purchase_Order_Fill] (NOLOCK) pof ON po.Purchase_Order_Fill_Key = pof.Purchase_Order_Fill_Key
		WHERE   po.Purchase_Order_Header_Accounting_Date >= '8/15/2020' 
				--AND po.Purchase_Line_Confirmed_Delivery_Date >= CAST(GETDATE() -1 AS DATE)
				AND pop.Purchase_Order_Header_Status IN ('Open','Received')
				AND pop.Purchase_Order_Line_Status IN ('Open','Received')
				AND pof.Purchase_Order_Fill_Status = 'Active'
				AND po.is_Removed_From_Source = 0
				--AND p.is_Currently_Backordered = 1
		GROUP BY po.Product_Key
	)

SELECT
	 [Product Key] = bo.[Backorder_Product_Key]
	,[Item Number - Name] = p.[Item Number Name]
	,[Item Number] = p.[Item Number]
	,p.[Color]
	,p.[Size]
	,[Backorder Amount] = bo.[Backorder_Amount]
	,[Backorder Average Unit Retail] = bo.Backorder_Average_Unit_Retail
	,[Backorder Quantity] = bo.[Backorder_Quantity]
	,[Backorder No Pick List Amount] = bo.[Backorder_No_Pick_List_Amount]
	,[Backorder No Pick List Quantity] = bo.[Backorder_No_Pick_List_Quantity]
	,[Backorder Pick List Amount] = bo.[Backorder_Pick_List_Amount]
	,[Backorder Pick List Quantity] = bo.[Backorder_Pick_List_Quantity]
	,[Ordered Quantity] = po.Ordered_Quantity
	,[Received Quantity] = po.Received_Quantity
	,[Open Quantity] = po.Open_Quantity--CASE WHEN (ISNULL(po.Ordered_Quantity,0) - ISNULL(po.Received_Quantity,0) >= 0) THEN ISNULL(po.Ordered_Quantity,0) - ISNULL(po.Received_Quantity,0)  ELSE 0 END

FROM Backorders_By_Item bo
		INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Products] p ON bo.Backorder_Product_Key = p.[Product Key]
		LEFT JOIN Purchase_Order_By_Item po ON bo.[Backorder_Product_Key] = po.Product_Key
	--WHERE Item_Number = '11729'
	;
