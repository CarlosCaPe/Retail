



CREATE VIEW [Data_Flow].[v_Fact_Purchase_Orders]

AS

SELECT [Purchase Order Key] = po.[Purchase_Order_Key]
      ,[Purchase Order Number] = [Purchase_Order_Number]
      ,[Purchase Order Line Number] = [Purchase_Order_Line_Number]
	  ,[Purchase Order Name] = [Purchase_Order_Name]
      ,[Purchase Order Description] = [Purchase_Line_Description]
      ,[Invent Trans ID] = [Invent_Trans_ID]
      ,[Delivery Location Key] = [Delivery_Location_Key]
      ,[Vendor Key] = v.[Vendor_Key]
      ,[Purchase Order Property Key] = po.[Purchase_Order_Property_Key]
      ,[Product Key] = p.[Product_Key]
	  ,[Purchase Order Fill Key] = po.[Purchase_Order_Fill_Key]

	  ,[Purchase Order Accounting Date Key] = ad.Date_Key
	  ,[Purchase Line Confirmed Delivery Date Key] = cd.Date_Key
	  ,[Purchase Line Delivery Date Key] = rd.Date_Key
      ,[Purchase Line Amount] = [Purchase_Line_Amount]
	  ,[Purchase Line Open Amount] = [Purchase_Line_Open_Amount]
	  ,[Purchase Line Received Amount] = [Purchase_Line_Received_Amount]
	  ,[Purchase Line Overfill Amount] = [Purchase_Line_Overfill_Amount]
      ,[Purchase Line Purchase Price] = [Purchase_Line_Purchase_Price] --Use [Purchase_Line_Cost]
	  ,[Purchase Line Cost] = po.[Purchase_Line_Purchase_Price]
      ,[Purchase Line Discount Amount] = [Purchase_Line_Discount_Amount]
      ,[Purchase Line Price Quantity] = [Purchase_Line_Price_Quantity]
      ,[Purchase Line Ordered Quantity] = [Purchase_Line_Ordered_Quantity]
	  ,[Purchase Line Received Quantity] = po.[Received_Quantity]
	  ,[Purchase Line Open Quantity] = po.[Open_Quantity]
	  ,[Purchase Line Overfill Quantity] = po.[Overfill_Quantity]
	/*,[Received_Status] = CASE 
								WHEN CAST(vps.[Received_Quantity] AS INT) = 0 THEN 'No Receipt'
								WHEN CAST(vps.[Received_Quantity] AS INT) = [Purchase_Line_Ordered_Quantity] THEN 'Full Receipt'
								WHEN CAST(vps.[Received_Quantity] AS INT) BETWEEN CAST(vps.[Received_Quantity] AS INT) AND [Purchase_Line_Ordered_Quantity] THEN 'Partial Receipt'
								WHEN CAST(vps.[Received_Quantity] AS INT) > [Purchase_Line_Ordered_Quantity] THEN 'Over Receipt'
							END
	  ,[Receipt_Percentage] = CASE WHEN [Purchase_Line_Ordered_Quantity] > 0 THEN vps.[Received_Quantity]/[Purchase_Line_Ordered_Quantity] ELSE 0 END					
	  */
	  ,[Commission Charge Percentage] = [Commission_Charge_Percentage]
      ,[Tariff Charge Percentage] = [Tariff_Charge_Percentage]
      ,[Duty Charge Percentage] = [Duty_Charge_Percentage]
      ,[Freight Charge Percentage] = [Freight_Charge_Percentage]
      ,[Freight In Charge Percentage] = [Freight_In_Charge_Percentage]

      ,[Commission Charge Amount] = [Commission_Charge_Amount]
      ,[Tariff Charge Amount] = [Tariff_Charge_Amount]
      ,[Duty Charge Amount] = [Duty_Charge_Amount]
      ,[Freight Charge Amount] = [Freight_Charge_Amount]
      ,[Freight-In Charge Amount] = [Freight_In_Charge_Amount]
	  ,[First Cost] = First_Cost
	  --,[Landed Cost] = ([Commission_Charge_Amount] + [Tariff_Charge_Amount] + [Duty_Charge_Amount] + [Freight_Charge_Amount] + [Freight_In_Charge_Amount] + [First_Cost])
	  ,[Retail Amount] = (p.[Trade_Agreement_Price] * [Purchase_Line_Ordered_Quantity])
	  --,[Trade Agreement Cost] = p.[Trade_Agreement_Cost]
	  --,[Trade Agreement Price] = p.[Trade_Agreement_Price]
	  --,[Purchase Order Header Status] = pop.Purchase_Order_Header_Status
	  --,[Purchase Order Line Status] = pop.Purchase_Order_Line_Status
	  --,[Purchase Order Line Status Index] = CASE pop.Purchase_Order_Line_Status WHEN 'Open' THEN 1 WHEN 'Received' THEN 2 WHEN 'Invoiced' THEN 3 WHEN 'Canceled' THEN 4 END
	  --,[Purchase Order Fill] = pof.Purchase_Order_Fill
	  --,[Purchase Order Line Fill] = pof.Purchase_Order_Line_Fill
	  --,[Purchase Order Fill Status] = pof.Purchase_Order_Fill_Status
	  --,[Purchase Order Line Fill Status] = pof.Purchase_Order_Line_Fill_Status
	  --,[Purchase Order Header Season] = pop.Purchase_Order_Header_Season
	  --,[Purchase Order Mode Of Delivery] = pop.Purchase_Order_Header_Delivery_Mode_ID
	  --,[Ship Mode] = pop.Ship_Mode
	  --,[Purchase Order Header Payment Terms] = pop.[Purchase_Order_Header_Payment_Terms_Name]
	  --,[Purchse Order Header Payment Method] = pop.[Purchase_Order_Header_Vendor_Payment_Method_Name]
	  --,[Purchase Order Header Buyer Group] = pop.Purchase_Order_Header_Buyer_Group_ID
	  --,[Vendor Account] = v.Vendor_Account_Number
	  --,[Vendor] = v.Vendor_Organization_Name
	  --,[Vendor Delivery Terms CD] = v.Default_Delivery_Terms_CD
	  --,[Vendor Delivery Terms Parent CD] = CASE WHEN LEFT(v.Default_Delivery_Terms_CD,2) = 'DD' THEN 'DDP'
			--									WHEN v.Default_Delivery_Terms_CD = 'FOBO' THEN 'FOBO'
			--									ELSE 'FOB' END
	  --,[Vendor Country] = v.Country_Name
	  --,p.is_Currently_Backordered
      --,[Barcode]
      --,[is_Removed_From_Source]
      --,[is_Excluded]
      --,[ETL_Created_Date]
      --,[ETL_Modified_Date]
      --,[ETL_Modified_Count]
  FROM [CWC_DW].[Fact].[Purchase_Orders] (NOLOCK) po
  LEFT JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] ad ON po.Purchase_Order_Header_Accounting_Date = ad.Calendar_Date
  LEFT JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] cd ON po.[Purchase_Line_Confirmed_Delivery_Date] = cd.Calendar_Date
  LEFT JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] rd ON po.[Purchase_Line_Requested_Delivery_Date] = rd.Calendar_Date
  --LEFT JOIN [Vendor_Packing_Slips] vps ON po.[Purchase_Order_Key] = vps.[Purchase_Order_Key]
  LEFT JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON po.Product_Key = p.Product_Key
  LEFT JOIN [CWC_DW].[Dimension].[Purchase_Order_Properties] (NOLOCK) pop ON pop.[Purchase_Order_Property_Key] = po.[Purchase_Order_Property_Key]
  LEFT JOIN [CWC_DW].[Dimension].[Purchase_Order_Fill] (NOLOCK) pof ON pof.[Purchase_Order_Fill_Key] = po.[Purchase_Order_Fill_Key]
  LEFT JOIN [CWC_DW].[Dimension].[Vendors] (NOLOCK) v ON po.Vendor_Key = v.Vendor_Key
  LEFT JOIN [CWC_DW].[Fact].[Trade_Agreement_Costs] tc ON po.Product_Key = tc.Product_Key AND CAST(GETDATE() AS DATE) BETWEEN tc.[Start_Date] AND tc.[End_Date] AND tc.is_Removed_From_Source = 0
  LEFT JOIN [CWC_DW].[Fact].[Trade_Agreement_Prices] tp ON po.Product_Key = tp.Product_Key AND CAST(GETDATE() AS DATE) BETWEEN tp.[Start_Date] AND tp.[End_Date] AND tp.is_Removed_From_Source = 0
  WHERE po.[Purchase_Order_Header_Accounting_Date] >= '8/15/2020' AND po.is_Removed_From_Source = 0 --and Purchase_Order_Number = '16134'
  ;


