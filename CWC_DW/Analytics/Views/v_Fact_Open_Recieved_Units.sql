








CREATE VIEW [Analytics].[v_Fact_Open_Recieved_Units]

AS

--Receipts

SELECT --TOP (1000) 
	 --[Vendor Packing Slip Key] = [Vendor_Packing_Slip_Key]
	 [Reporting Date] = [Vendor_Packing_Accounting_Date]
	,[Record Type] = 'Receipt'
	--,[Purchase Order Key] = vps.[Purchase_Order_Key]
	,[Purchase Order Number] = vps.[Purchase_Order_Number]
    ,[Line Number] = vps.[Purchase_Order_Line_Number]
	,[Status] = pop.Purchase_Order_Line_Status
	,[Season] = pop.Purchase_Order_Header_Season
    --,[Invent Trans ID] = [Invent_Trans_ID]
	,[Product Key] = vps.Product_Key
	--,[Reporting Date Key] = d.Date_Key
	
	--,[Fiscal Week Short] = d.Fiscal_Week_of_Year_Name
	--,[Fiscal Week] = [Fiscal_Month_Year_Week_Name]
	--,[Fiscal Week Index] = DENSE_RANK() OVER(ORDER BY CAST(d.[Fiscal_Year] AS VARCHAR(4)),CAST(100 + d.[Fiscal_Week_of_Year] AS VARCHAR(3)))
	--,[Receipt Date] = [Vendor_Packing_Accounting_Date]
	--,[Receipt Quantity] = [Vendor_Packing_Slip_Quantity]
	--,[Confirmed Delivery Date] = NULL
	--,[Open Quantity] = NULL
	,[Units] = [Vendor_Packing_Slip_Quantity]
	--,[Commission Charge Percentage]
	--,[Tariff Charge Percentage]
	--,[Duty Charge Percentage]
	--,[Freight Charge Percentage]
	--,[Freight In Charge Percentage]
	,[Commission Charge Amount] = ([Commission_Charge_Percentage]/100)*([Purchase_Line_Purchase_Price])*([Vendor_Packing_Slip_Quantity])
	,[Tariff Charge Amount] = ([Tariff_Charge_Percentage]/100)*([Purchase_Line_Purchase_Price])*([Vendor_Packing_Slip_Quantity])
	,[Duty Charge Amount]  = ([Duty_Charge_Percentage]/100)*([Purchase_Line_Purchase_Price])*([Vendor_Packing_Slip_Quantity])
	,[Freight Charge Amount] = ([Freight_Charge_Percentage]/100)*([Purchase_Line_Purchase_Price])*([Vendor_Packing_Slip_Quantity])
	,[Freight In Charge Amount] = ([Freight_In_Charge_Percentage]/100)*([Purchase_Line_Purchase_Price])*([Vendor_Packing_Slip_Quantity])
	--,[Landed Cost] = 
	--  ISNULL(([Commission_Charge_Percentage]/100)*([Purchase_Line_Purchase_Price])*([Vendor_Packing_Slip_Quantity]),0)
	--+ ISNULL(([Tariff_Charge_Percentage]/100)*([Purchase_Line_Purchase_Price])*([Vendor_Packing_Slip_Quantity]),0)
	--+ ISNULL(([Duty_Charge_Percentage]/100)*([Purchase_Line_Purchase_Price])*([Vendor_Packing_Slip_Quantity]),0)
	--+ ISNULL(([Freight_Charge_Percentage]/100)*([Purchase_Line_Purchase_Price])*([Vendor_Packing_Slip_Quantity]),0)
	--+ ISNULL(([Freight_In_Charge_Percentage]/100)*([Purchase_Line_Purchase_Price])*([Vendor_Packing_Slip_Quantity]),0)
	--+ ISNULL(([Purchase_Line_Purchase_Price]*[Vendor_Packing_Slip_Quantity]),0)
	,[First Cost] = ([Purchase_Line_Purchase_Price]*[Vendor_Packing_Slip_Quantity])
	,[Retail Amount] = NULLIF((tap.Price * [Vendor_Packing_Slip_Quantity]),0)
	--,[Retail Amount PO] = NULLIF((po.[Trade Agreement Price] * [Vendor_Packing_Slip_Quantity]),0)
	,[Vendor] = v.Vendor_Organization_Name
	--,[Vendor Country] = v.Country_Name
	,[Delivery Terms] = v.Default_Delivery_Terms_CD
	--,[Delivery Terms Parent CD] = po.[Vendor Delivery Terms Parent CD]
	,[Payment Terms] = pop.Purchase_Order_Header_Payment_Terms_Name
	,[Ship Mode] = pop.Ship_Mode
	,[Starts With 9] = CAST(CASE WHEN LEFT(po.Purchase_Order_Number,1) = '9' THEN 1 ELSE 0 END AS BIT)
FROM [CWC_DW].[Fact].[Vendor_Packing_Slips] (NOLOCK) vps
INNER JOIN [CWC_DW].[Fact].[Purchase_Orders] (NOLOCK) po ON vps.Purchase_Order_Key = po.[Purchase_Order_Key]
--INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) d ON vps.Vendor_Packing_Accounting_Date = d.Calendar_Date
LEFT JOIN [CWC_DW].[Dimension].[Purchase_Order_Properties] (NOLOCK) pop ON po.Purchase_Order_Property_Key = pop.Purchase_Order_Property_Key
LEFT JOIN [CWC_DW].[Fact].[Trade_Agreement_Prices] tap (NOLOCK) ON po.Product_Key = tap.Product_Key AND DATEADD(WEEK,5,po.Purchase_Line_Confirmed_Delivery_Date) BETWEEN tap.Start_Date AND tap.End_Date AND tap.is_Removed_From_Source = 0
LEFT JOIN [CWC_DW].[Dimension].[Vendors] (NOLOCK) v ON po.Vendor_Key = v.Vendor_Key
WHERE [Vendor_Packing_Accounting_Date] >= '8/15/2020' 
AND [Vendor_Packing_Slip_Quantity] > 0
AND LEFT(po.Purchase_Order_Number,1) <> '9'


UNION ALL

--Open

SELECT --TOP (1000) 
	 --[Vendor Packing Slip Key] = [Vendor_Packing_Slip_Key]
	 [Reporting Date] = po.Purchase_Line_Confirmed_Delivery_Date
	,[Record Type] = 'Open'
	--,[Purchase Order Key] = po.Purchase_Order_Key
	,[Purchase Order Number] = po.Purchase_Order_Number
    ,[Line Number] = po.Purchase_Order_Line_Number
	,[Status] = pop.Purchase_Order_Line_Status
	,[Season] = pop.Purchase_Order_Header_Season
    --,[Invent Trans ID] = [Invent Trans ID]
	,[Product Key] = po.[Product_Key]
	--,[Reporting Date Key] = d.Date_Key
	
	--,[Fiscal Week Short] = d.Fiscal_Week_of_Year_Name
	--,[Fiscal Week] = [Fiscal_Month_Year_Week_Name]
	--,[Fiscal Week Index] = DENSE_RANK() OVER(ORDER BY d.[Fiscal_Year],100 + d.[Fiscal_Week_of_Year])
	--,[Receipt Date] = NULL
	--,[Receipt Quantity] = NULL
	--,[Confirmed Delivery Date] = po.[Purchase Line Confirmed Delivery Date]
	--,[Open Quantity] = po.[Purchase Line Open Quantity]
	,[Units] = po.Open_Quantity
	--,[Commission Charge Percentage]
	--,[Tariff Charge Percentage]
	--,[Duty Charge Percentage]
	--,[Freight Charge Percentage]
	--,[Freight In Charge Percentage]
	,[Commission Charge Amount] = ([Commission_Charge_Percentage]/100)*([Purchase_Line_Purchase_Price])*(po.[Open_Quantity])
	,[Tariff Charge Amount] = ([Tariff_Charge_Percentage]/100)*([Purchase_Line_Purchase_Price])*(po.[Open_Quantity])
	,[Duty Charge Amount]  = ([Duty_Charge_Percentage]/100)*([Purchase_Line_Purchase_Price])*(po.[Open_Quantity])
	,[Freight Charge Amount] = ([Freight_Charge_Percentage]/100)*([Purchase_Line_Purchase_Price])*(po.[Open_Quantity])
	,[Freight In Charge Amount] = ([Freight_In_Charge_Percentage]/100)*([Purchase_Line_Purchase_Price])*(po.[Open_Quantity])
	--,[Landed Cost] = 
	--  ISNULL(([Commission_Charge_Percentage]/100)*([Purchase_Line_Purchase_Price])*(po.[Open_Quantity]),0)
	--+ ISNULL(([Tariff_Charge_Percentage]/100)*([Purchase_Line_Purchase_Price])*(po.[Open_Quantity]),0)
	--+ ISNULL(([Duty_Charge_Percentage]/100)*([Purchase_Line_Purchase_Price])*(po.[Open_Quantity]),0)
	--+ ISNULL(([Freight_Charge_Percentage]/100)*([Purchase_Line_Purchase_Price])*(po.[Open_Quantity]),0)
	--+ ISNULL(([Freight_In_Charge_Percentage]/100)*([Purchase_Line_Purchase_Price])*(po.[Open_Quantity]),0)
	--+ ISNULL(([Purchase_Line_Purchase_Price]*po.[Open_Quantity]),0)
	,[First Cost] = ([Purchase_Line_Purchase_Price]*po.[Open_Quantity])
	,[Retail Amount] = NULLIF((tap.Price * po.Open_Quantity),0)
	--,[Retail Amount TA] = NULLIF((po.[Trade Agreement Price] * [Purchase Line Open Quantity]),0)
	,[Vendor] = v.Vendor_Organization_Name
	--,[Vendor Country] = v.Country_Name
	,[Delivery Terms] = v.Default_Delivery_Terms_CD
	--,[Delivery Terms Parent CD] = po.[Vendor Delivery Terms Parent CD]
	,[Payment Terms] = pop.Purchase_Order_Header_Payment_Terms_Name
	,[Ship Mode] = pop.Ship_Mode
	,[Starts With 9] = CAST(CASE WHEN LEFT(po.Purchase_Order_Number,1) = '9' THEN 1 ELSE 0 END AS BIT)
FROM [CWC_DW].[Fact].[Purchase_Orders] (NOLOCK) po --ON vps.Purchase_Order_Key = po.[Purchase Order Key]
LEFT JOIN [CWC_DW].[Dimension].[Purchase_Order_Properties] (NOLOCK) pop ON po.Purchase_Order_Property_Key = pop.Purchase_Order_Property_Key
LEFT JOIN [CWC_DW].[Fact].[Trade_Agreement_Prices] tap (NOLOCK) ON po.Product_Key = tap.Product_Key AND DATEADD(WEEK,5,po.Purchase_Line_Confirmed_Delivery_Date) BETWEEN tap.Start_Date AND tap.End_Date AND tap.is_Removed_From_Source = 0
LEFT JOIN [CWC_DW].[Dimension].[Vendors] (NOLOCK) v ON po.Vendor_Key = v.Vendor_Key
WHERE po.Purchase_Order_Header_Accounting_Date >= '8/15/2020'
AND pop.Purchase_Order_Header_Status IN ('Open','Received') 
AND po.Open_Quantity > 0
AND LEFT(po.Purchase_Order_Number,1) <> '9';

