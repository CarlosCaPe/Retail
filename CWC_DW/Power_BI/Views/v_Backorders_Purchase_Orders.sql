


CREATE VIEW [Power_BI].[v_Backorders_Purchase_Orders] AS




WITH Backorders_By_Item AS
	(
		SELECT
			 [Backorder_Amount] = SUM(([Sales_Line_Amount]/[Sales_Line_Ordered_Sales_Quantity]) * [Sales_Line_Remain_Sales_Physical])
			,[Backorder_Quantity] = SUM([Sales_Line_Remain_Sales_Physical])
			,[Backorder_Average_Unit_Retail] = (SUM(([Sales_Line_Amount]/[Sales_Line_Ordered_Sales_Quantity]) * [Sales_Line_Remain_Sales_Physical]))/SUM([Sales_Line_Remain_Sales_Physical])
			,[Backorder_Product_Key] = b.Sales_Line_Product_Key
		FROM [CWC_DW].[Fact].[Backorders] (NOLOCK) b
			INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) sd ON b.[Snapshot_Date_Key] = sd.[Date_Key]
			INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) bd ON CAST(b.[Sales_Line_Created_Date] AS DATE) = bd.[Calendar_Date]
			INNER JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON b.Sales_Line_Product_Key = p.Product_Key
			LEFT JOIN [CWC_DW].[Fact].[Purchase_Orders] (NOLOCK) po ON p.Earliest_Open_Purchase_Order_Key = po.Purchase_Order_Key
		WHERE sd.Current_Backorder_Date = 'Current Backorder Date'
		AND b.is_Removed_From_Source = 0
		--AND Item_ID = '11729'
		GROUP BY b.Sales_Line_Product_Key
	) --SELECT * FROM BO
--,Vendor_Packing_Slips_By_PO AS
--	(
--		SELECT Purchase_Order_Key
--			  ,Received_Quantity = SUM(CAST(ISNULL([Vendor_Packing_Slip_Quantity],0) AS INT))
--		FROM [CWC_DW].[Fact].[Vendor_Packing_Slips] (NOLOCK)
--		--WHERE Purchase_Order_Number = '17689'
--		GROUP BY Purchase_Order_Key
--	)
,Purchase_Orders AS
	(
		SELECT
			 po.Purchase_Order_Key
			,[Item Number - Name] = p.[Item Number Name]
			,[Item Number] = p.[Item Number]
			,p.[Color]
			,p.[Size]
			,[Purchase Order Number] = po.Purchase_Order_Number
			,[Purchase Order Line Number] = po.Purchase_Order_Line_Number
			,[Product Key] = po.Product_Key
			,[Ordered Quantity] = po.Purchase_Line_Ordered_Quantity
			,[Received Quantity] = po.Received_Quantity
			,[Open Quantity] = po.Open_Quantity
			,[Purchase Line Confirmed Delivery Date] = po.Purchase_Line_Confirmed_Delivery_Date
			--,[Confirmed Fiscal Week] = cd.Fiscal_Month_Year_Week_Name
			,[Purchase Order Header Status] = pop.Purchase_Order_Header_Status
			,[Purchase Order Line Status] = pop.Purchase_Order_Line_Status
			,[Confirmed Fiscal Week] = cd.Fiscal_Week_of_Year_Name + ' (' + CAST(cd.Fiscal_Year AS VARCHAR(4)) + ')'
			,[Confirmed_Fiscal_Week_Index] = CAST(CAST(cd.Fiscal_Year AS VARCHAR(4)) + CAST((cd.Fiscal_Week_of_Year + 10) AS VARCHAR(2)) AS INT)
			,[Confirmed Delivery Date Status] = CASE WHEN po.Purchase_Line_Confirmed_Delivery_Date IS NULL THEN 'No Date' ELSE cd.Date_Status END
			,[Confirmed Delivery Date Status Index] = CASE 
														WHEN po.Purchase_Line_Confirmed_Delivery_Date  IS NULL THEN 1 
														WHEN cd.Date_Status = 'Past Date' THEN 2 
														WHEN cd.Date_Status = 'Current Date' THEN 3
														WHEN cd.Date_Status = 'Future Date' THEN 4
													END
			,[Confirmed Delivery Fiscal Week Status] = cd.Fiscal_Week_Status
			,[Confirmed Delivery Fiscal Week Status Index] = CASE 
														WHEN po.Purchase_Line_Confirmed_Delivery_Date  IS NULL THEN 1 
														WHEN cd.Fiscal_Week_Status = 'Past Fiscal Week' THEN 2 
														WHEN cd.Fiscal_Week_Status = 'Current Fiscal Week' THEN 3
														WHEN cd.Fiscal_Week_Status = 'Future Fiscal Week' THEN 4
													END
			--,[Backorder_Amount]
			--,[Backorder_Quantity]
			--,[Backorder_Average_Unit_Retail]
			--,Seq = ROW_NUMBER() OVER(ORDER BY (cd.Fiscal_Month + cd.Fiscal_Week_of_Year + cd.Fiscal_Year))
			--,cd.Fiscal_Week_of_Year_Name + ' ' + cd.Fiscal_Year
		FROM [CWC_DW].[Fact].[Purchase_Orders] (NOLOCK) po
			INNER JOIN Backorders_By_Item bo ON po.Product_Key = bo.Backorder_Product_Key
			INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Purchase_Order_Properties] (NOLOCK) pop ON po.Purchase_Order_Property_Key = pop.Purchase_Order_Property_Key
			LEFT JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] ad ON po.Purchase_Order_Header_Accounting_Date = ad.Calendar_Date
			LEFT JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] cd ON po.[Purchase_Line_Confirmed_Delivery_Date] = cd.Calendar_Date
			--LEFT JOIN Vendor_Packing_Slips_By_PO vps ON po.[Purchase_Order_Key] = vps.[Purchase_Order_Key]
			LEFT JOIN [CWC_DW].[Power_BI].[v_Dim_Products] (NOLOCK) p ON po.Product_Key = p.[Product Key]
			INNER JOIN [CWC_DW].[Dimension].[Purchase_Order_Fill] (NOLOCK) pof ON po.Purchase_Order_Fill_Key = pof.Purchase_Order_Fill_Key
		WHERE   po.Purchase_Order_Header_Accounting_Date >= '8/15/2020' 
				--AND cd.Fiscal_Week_Status IN ('Current Fiscal Week','Future Fiscal Week')
				AND pop.Purchase_Order_Header_Status IN ('Open','Received')
				AND pop.Purchase_Order_Line_Status IN ('Open','Received')
				AND pof.Purchase_Order_Fill_Status = 'Active'
				AND pof.Purchase_Order_Line_Fill_Status = 'Active'
				AND po.is_Removed_From_Source = 0
				--AND po.Product_Key = 8386
				--AND p.is_Currently_Backordered = 1				
	)

	SELECT
		     pc.[Purchase Order Number]
			,pc.[Purchase Order Line Number]
			,pc.[Product Key]
			,pc.[Item Number - Name]
			,pc.[Item Number]
			,pc.[Color]
			,pc.[Size]
			,pc.[Ordered Quantity]
			,pc.[Received Quantity]
			,pc.[Open Quantity]
			,pc.[Purchase Line Confirmed Delivery Date]
			,pc.[Purchase Order Header Status] 
			,pc.[Purchase Order Line Status]
			,pc.[Confirmed Fiscal Week]
			,pc.[Confirmed_Fiscal_Week_Index]
			,[Confirmed Delivery Date Status]
			,[Confirmed Delivery Date Status Index]
			,[Confirmed Delivery Fiscal Week Status]
			,[Confirmed Delivery Fiscal Week Status Index]
FROM Purchase_Orders pc;

