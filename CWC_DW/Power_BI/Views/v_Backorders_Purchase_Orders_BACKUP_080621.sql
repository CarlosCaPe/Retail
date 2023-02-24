



CREATE VIEW [Power_BI].[v_Backorders_Purchase_Orders_BACKUP_080621] AS



WITH Backorders_By_Item AS
	(
		SELECT
				[Backorder_Product_Key] = b.Sales_Line_Product_Key
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
,Vendor_Packing_Slips_By_PO AS
	(
		SELECT Purchase_Order_Key
			  ,Received_Quantity = SUM(CAST(ISNULL([Vendor_Packing_Slip_Quantity],0) AS INT))
		FROM [CWC_DW].[Fact].[Vendor_Packing_Slips] (NOLOCK)
		--WHERE Purchase_Order_Number = '17689'
		GROUP BY Purchase_Order_Key
	)
--,Purchase_Order_By_Item AS
--	(
		SELECT
			 [Purchase Order Number] = po.Purchase_Order_Number
			,[Purchase Order Line Number] = po.Purchase_Order_Line_Number
			,[Product Key] = po.Product_Key
			,[Ordered Quantity] = po.Purchase_Line_Ordered_Quantity
			,[Received Quantity] = vps.Received_Quantity
			,[Open Quantity] = CASE WHEN (po.Purchase_Line_Ordered_Quantity - vps.Received_Quantity) >= 0 THEN (po.Purchase_Line_Ordered_Quantity - vps.Received_Quantity) 
									WHEN vps.Received_Quantity IS NULL THEN po.Purchase_Line_Ordered_Quantity
							   ELSE 0 END
			,[Purchase Line Confirmed Delivery Date] = po.Purchase_Line_Confirmed_Delivery_Date
			--,[Confirmed Fiscal Week] = cd.Fiscal_Month_Year_Week_Name
			,[Purchase Order Header Status] = pop.Purchase_Order_Header_Status
			,[Purchase Order Line Status] = pop.Purchase_Order_Line_Status

		FROM [CWC_DW].[Fact].[Purchase_Orders] (NOLOCK) po
			INNER JOIN Backorders_By_Item bo ON po.Product_Key = bo.Backorder_Product_Key
			INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Purchase_Order_Properties] (NOLOCK) pop ON po.Purchase_Order_Property_Key = pop.Purchase_Order_Property_Key
			LEFT JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] ad ON po.Purchase_Order_Header_Accounting_Date = ad.Calendar_Date
			LEFT JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] cd ON po.[Purchase_Line_Confirmed_Delivery_Date] = cd.Calendar_Date
			LEFT JOIN Vendor_Packing_Slips_By_PO vps ON po.[Purchase_Order_Key] = vps.[Purchase_Order_Key]
			LEFT JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON po.Product_Key = p.Product_Key
			INNER JOIN [CWC_DW].[Dimension].[Purchase_Order_Fill] (NOLOCK) pof ON po.Purchase_Order_Fill_Key = pof.Purchase_Order_Fill_Key
		WHERE   po.Purchase_Order_Header_Accounting_Date >= '8/15/2020' 
				--AND po.Purchase_Line_Confirmed_Delivery_Date >= CAST(GETDATE() -1 AS DATE)
				AND pop.Purchase_Order_Header_Status IN ('Open','Received')
				AND pop.Purchase_Order_Line_Status IN ('Open','Received')
				AND pof.Purchase_Order_Fill_Status = 'Active'
				AND po.is_Removed_From_Source = 0
				--AND p.is_Currently_Backordered = 1
				;
