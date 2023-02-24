


CREATE VIEW [Power_BI].[v_Purchase_Order_Line_Open_Receipt_Units2]
AS

--Receipts

SELECT --TOP (1000) 
	 --[Vendor Packing Slip Key] = [Vendor_Packing_Slip_Key]
	 [Record Type] = 'Receipt'
	,[Purchase Order Key] = [Purchase_Order_Key]
	,[Purchase Order Number] = [Purchase_Order_Number]
    ,[Purchase Order Line Number] = [Purchase_Order_Line_Number]
	,po.[Purchase Order Line Status]
	,[Purchase Order Season] = po.[Purchase Order Header Season]
    ,[Invent Trans ID] = [Invent_Trans_ID]
	,[Product Key] = Product_Key
	,[Reporting Date Key] = d.Date_Key
	,[Reporting Date] = [Vendor_Packing_Accounting_Date]
	,[Fiscal Week Short] = d.Fiscal_Week_of_Year_Name
	,[Fiscal Week] = [Fiscal_Month_Year_Week_Name]
	,[Fiscal Week Index] = DENSE_RANK() OVER(ORDER BY CAST(d.[Fiscal_Year] AS VARCHAR(4)),CAST(100 + d.[Fiscal_Week_of_Year] AS VARCHAR(3)))
	,[Receipt Date] = [Vendor_Packing_Accounting_Date]
	,[Receipt Quantity] = [Vendor_Packing_Slip_Quantity]
	,[Confirmed Delivery Date] = NULL
	,[Open Quantity] = NULL
	,[Units] = [Vendor_Packing_Slip_Quantity]
	,[Commission Charge Percentage]
	,[Tariff Charge Percentage]
	,[Duty Charge Percentage]
	,[Freight Charge Percentage]
	,[Freight In Charge Percentage]
	,[Commission Charge Amount] = ([Commission Charge Percentage]/100)*([Purchase Line Purchase Price])*([Vendor_Packing_Slip_Quantity])
	,[Tariff Charge Amount] = ([Tariff Charge Percentage]/100)*([Purchase Line Purchase Price])*([Vendor_Packing_Slip_Quantity])
	,[Duty Charge Amount]  = ([Duty Charge Percentage]/100)*([Purchase Line Purchase Price])*([Vendor_Packing_Slip_Quantity])
	,[Freight Charge Amount] = ([Freight Charge Percentage]/100)*([Purchase Line Purchase Price])*([Vendor_Packing_Slip_Quantity])
	,[Freight In Charge Amount] = ([Freight In Charge Percentage]/100)*([Purchase Line Purchase Price])*([Vendor_Packing_Slip_Quantity])
	,[Landed Cost] = 
	  ISNULL(([Commission Charge Percentage]/100)*([Purchase Line Purchase Price])*([Vendor_Packing_Slip_Quantity]),0)
	+ ISNULL(([Tariff Charge Percentage]/100)*([Purchase Line Purchase Price])*([Vendor_Packing_Slip_Quantity]),0)
	+ ISNULL(([Duty Charge Percentage]/100)*([Purchase Line Purchase Price])*([Vendor_Packing_Slip_Quantity]),0)
	+ ISNULL(([Freight Charge Percentage]/100)*([Purchase Line Purchase Price])*([Vendor_Packing_Slip_Quantity]),0)
	+ ISNULL(([Freight In Charge Percentage]/100)*([Purchase Line Purchase Price])*([Vendor_Packing_Slip_Quantity]),0)
	+ ISNULL(([Purchase Line Purchase Price]*[Vendor_Packing_Slip_Quantity]),0)
	,[First Cost] = ([Purchase Line Purchase Price]*[Vendor_Packing_Slip_Quantity])
	,[Retail Amount] = NULLIF((po.[Trade Agreement Price] * [Vendor_Packing_Slip_Quantity]),0)
	--,[Retail Amount PO] = NULLIF((po.[Trade Agreement Price] * [Vendor_Packing_Slip_Quantity]),0)
	,po.Vendor
	,po.[Vendor Country]
	,[Delivery Terms CD] = po.[Vendor Delivery Terms CD]
	,[Delivery Terms Parent CD] = po.[Vendor Delivery Terms Parent CD]
	,[Payment Terms] = po.[Purchase Order Header Payment Terms]
	,[Ship Mode] = [Ship Mode]
FROM [CWC_DW].[Fact].[Vendor_Packing_Slips] (NOLOCK) vps
INNER JOIN [CWC_DW].[Power_BI].[v_Fact_Purchase_Orders] (NOLOCK) po ON vps.Purchase_Order_Key = po.[Purchase Order Key]
INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) d ON vps.Vendor_Packing_Accounting_Date = d.Calendar_Date
WHERE [Vendor_Packing_Accounting_Date] >= '8/15/2020' AND [Vendor_Packing_Slip_Quantity] > 0


UNION ALL

--Open

SELECT --TOP (1000) 
	 --[Vendor Packing Slip Key] = [Vendor_Packing_Slip_Key]
	 [Record Type] = 'Open'
	,[Purchase Order Key] = po.[Purchase Order Key]
	,[Purchase Order Number] = po.[Purchase Order Number]
    ,[Purchase Order Line Number] = po.[Purchase Order Line Number]
	,po.[Purchase Order Line Status]
	,[Purchase Order Season] = po.[Purchase Order Header Season]
    ,[Invent Trans ID] = [Invent Trans ID]
	,[Product Key] = po.[Product Key]
	,[Reporting Date Key] = d.Date_Key
	,[Reporting Date] = po.[Purchase Line Confirmed Delivery Date]
	,[Fiscal Week Short] = d.Fiscal_Week_of_Year_Name
	,[Fiscal Week] = [Fiscal_Month_Year_Week_Name]
	,[Fiscal Week Index] = DENSE_RANK() OVER(ORDER BY d.[Fiscal_Year],100 + d.[Fiscal_Week_of_Year])
	,[Receipt Date] = NULL
	,[Receipt Quantity] = NULL
	,[Confirmed Delivery Date] = po.[Purchase Line Confirmed Delivery Date]
	,[Open Quantity] = po.[Purchase Line Open Quantity]
	,[Units] = po.[Purchase Line Open Quantity]
	,[Commission Charge Percentage]
	,[Tariff Charge Percentage]
	,[Duty Charge Percentage]
	,[Freight Charge Percentage]
	,[Freight In Charge Percentage]
	,[Commission Charge Amount] = ([Commission Charge Percentage]/100)*([Purchase Line Purchase Price])*([Purchase Line Open Quantity])
	,[Tariff Charge Amount] = ([Tariff Charge Percentage]/100)*([Purchase Line Purchase Price])*([Purchase Line Open Quantity])
	,[Duty Charge Amount]  = ([Duty Charge Percentage]/100)*([Purchase Line Purchase Price])*([Purchase Line Open Quantity])
	,[Freight Charge Amount] = ([Freight Charge Percentage]/100)*([Purchase Line Purchase Price])*([Purchase Line Open Quantity])
	,[Freight In Charge Amount] = ([Freight In Charge Percentage]/100)*([Purchase Line Purchase Price])*([Purchase Line Open Quantity])
	,[Landed Cost] = 
	  ISNULL(([Commission Charge Percentage]/100)*([Purchase Line Purchase Price])*([Purchase Line Open Quantity]),0)
	+ ISNULL(([Tariff Charge Percentage]/100)*([Purchase Line Purchase Price])*([Purchase Line Open Quantity]),0)
	+ ISNULL(([Duty Charge Percentage]/100)*([Purchase Line Purchase Price])*([Purchase Line Open Quantity]),0)
	+ ISNULL(([Freight Charge Percentage]/100)*([Purchase Line Purchase Price])*([Purchase Line Open Quantity]),0)
	+ ISNULL(([Freight In Charge Percentage]/100)*([Purchase Line Purchase Price])*([Purchase Line Open Quantity]),0)
	+ ISNULL(([Purchase Line Purchase Price]*[Purchase Line Open Quantity]),0)
	,[First Cost] = ([Purchase Line Purchase Price]*[Purchase Line Open Quantity])
	,[Retail Amount] = NULLIF((po.[Trade Agreement Price] * [Purchase Line Open Quantity]),0)
	--,[Retail Amount TA] = NULLIF((po.[Trade Agreement Price] * [Purchase Line Open Quantity]),0)
	,po.Vendor
	,po.[Vendor Country]
	,[Delivery Terms CD] = po.[Vendor Delivery Terms CD]
	,[Delivery Terms Parent CD] = po.[Vendor Delivery Terms Parent CD]
	,[Payment Terms] = po.[Purchase Order Header Payment Terms]
	,[Ship Mode] = [Ship Mode]
FROM [CWC_DW].[Power_BI].[v_Fact_Purchase_Orders] (NOLOCK) po --ON vps.Purchase_Order_Key = po.[Purchase Order Key]
INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) d ON po.[Purchase_Line_Confirmed_Delivery_Date_Key] = d.Date_Key
WHERE po.[Purchase Order Header Accounting Date] >= '8/15/2020'
AND po.[Purchase Order Line Status] IN ('Open','Received') AND po.[Purchase Line Open Quantity] > 0;

