


CREATE VIEW [Data_Flow].[v_Fact_Transactions]

AS

WITH Invoices AS
(
SELECT
	 i.[Sales_Key]
	,[Invoice_Number] = MIN(Invoice_Number)
	,[Invoice_Count] = COUNT(i.Invoice_Key)
	,[Invoice_Key] = MIN(i.Invoice_Key)
	,[Invoice_Date] = MIN(i.[Invoice_Line_Date])
	,[Invoice_Amount] = SUM(i.[Invoice_Line_Amount])
	,[Invoice_Quantity] = SUM(i.[Invoice_Line_Quantity])
	,[Invoice_Tax_Amount] = SUM(i.[Invoice_Line_Tax_Amount])
	,[Invoice_Total_Charge_Amount] = SUM(i.Invoice_Header_Total_Charge_Amount)
	,[Baked] = SUM(CAST(ia.is_Baked AS TINYINT))
FROM [CWC_DW].[Fact].[Invoices] (NOLOCK) i
	INNER JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON i.[Invoice_Line_Product_Key] = p.[Product_Key]
	INNER JOIN [CWC_DW].[Dimension].[Invoice_Attributes] (NOLOCK) ia ON i.Invoice_Attribute_Key = ia.Invoice_Attribute_Key
--WHERE i.[Invoice_Line_Quantity] > 0
--	AND i.[Invoice_Line_Date] >= '12/01/2020'
--	AND p.[Item_ID] NOT IN ('CreditOnly')
GROUP BY i.[Sales_Key]
)
,Returns_Original AS
(
SELECT
	 s.Invent_Trans_ID
	,[Original_Invoice_Key] = ir.[Invoice_Key]
	,[Original_Sales_Date] = CAST(s.Sales_Line_Created_Date_EST AS DATE)
	,[Original_Sales_Order_Number] = s.Sales_Order_Number
	,[Original_Sales_Order_Line_Number] = s.Sales_Line_Number
	,[Original_is_Baked] = CASE WHEN ir.Baked > 0 THEN 1 ELSE 0 END
	,[Seq] = ROW_NUMBER() OVER(PARTITION BY s.Invent_Trans_ID ORDER BY s.Sales_Line_Created_Date_EST ASC,s.Sales_Order_Number ASC)
FROM [CWC_DW].[Fact].[Sales] (NOLOCK) s
LEFT JOIN Invoices ir ON ir.Sales_Key = s.Sales_Key
WHERE CAST(s.[Sales_Line_Created_Date_EST] AS DATE) >= '12/1/2020'

) --SELECT * FROM Returns_Original

SELECT --TOP 10000
	 [Sales Key] = s.Sales_Key
	,[Sales Date Est Key] = d.Date_Key
	,[Product Key] = s.Sales_Line_Product_Key
	,[Sales Order Attribute Key] = s.[Sales_Order_Attribute_Key]
	,[Shipping Inventory Warehouse Key] = s.Shipping_Inventory_Warehouse_Key
	,[Delivery Location Key] = s.Sales_Header_Location_Key
	,[Sales Header Property Key] = s.Sales_Header_Property_Key
	,[Sales Line Property Key] = s.Sales_Line_Property_Key
	,[Sales Order Fill Key] = s.Sales_Order_Fill_Key
	,[Employee Key] = s.Sales_Line_Employee_Key
	,[Baked Key] = CASE WHEN ro.Original_is_Baked > 0 OR i.Baked  > 0 THEN 1 ELSE 2 END -- If SO is baked or Original Sales Order to the return is baked

	,[Sales Order Number] = s.Sales_Order_Number
	,[Sales Line Number] = s.Sales_Line_Number

	,[Retail Price] = ISNULL(NULLIF(s.Sales_Line_Price,0),NULLIF(tp.Price,0))
	,[Cost Price] = ISNULL(NULLIF(s.Sales_Line_Cost_Price,0),NULLIF(tc.Cost,0))

	,[Lot ID] = s.Invent_Trans_ID

	,[Sales Line Ordered Quantity] = s.[Sales_Line_Ordered_Quantity]
	,[Sales Line Amount] = s.Sales_Line_Amount
	,[Sales Line Discount Amount] = s.Sales_Line_Discount_Amount
	,[Sales Line Remain Sales Physical] = s.[Sales_Line_Remain_Sales_Physical]
	--,[Sales Line Created By] = [Sales_Line_Created_By]

	--,[Original Invoice Key] = ro.[Original_Invoice_Key]
	,[Original Sales Date] = ro.Original_Sales_Date
	,[Original Sales Order Number] = ro.Original_Sales_Order_Number
	,[Original Sales Order Line Number] = ro.Original_Sales_Order_Line_Number
	,[Original is Baked] = ro.Original_is_Baked

	
	,[Sales Invoice Number] = i.[Invoice_Number]
	,[Sales Invoice Amount] = i.Invoice_Amount
	,[Sales Invoice Tax Amount] = i.[Invoice_Tax_Amount] 
	,[Sales Invoice Count] = i.[Invoice_Count]
	,[Sales Invoice Total Charge Amount] = i.[Invoice_Total_Charge_Amount]

FROM [CWC_DW].[Fact].[Sales] (NOLOCK) s
	  LEFT JOIN Returns_Original ro ON s.Return_Invent_Trans_ID = ro.Invent_Trans_ID AND ro.Seq = 1
	  INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) d ON d.Calendar_Date = CAST(s.[Sales_Line_Created_Date_est] AS DATE)
	  --INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes] (NOLOCK) soa ON s.[Sales_Order_Attribute_Key] = soa.[Sales_Order_Attribute_Key]
	  --INNER JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON s.Sales_Line_Product_Key = p.[Product_Key]
	  --INNER JOIN [CWC_DW].[Dimension].[Inventory_Warehouses] (NOLOCK) iw ON s.Shipping_Inventory_Warehouse_Key = iw.Inventory_Warehouse_Key
	  --INNER JOIN [CWC_DW].[Dimension].[Sales_Line_Properties] (NOLOCK) slp ON s.Sales_Line_Property_Key = slp.Sales_Line_Property_Key
	  --LEFT JOIN [CWC_DW].[Dimension].[Sales_Header_Properties] (NOLOCK) shp ON s.Sales_Header_Property_Key = shp.Sales_Header_Property_Key
	  --LEFT JOIN [CWC_DW].[Dimension].[Sales_Order_Fill] (NOLOCK) sof ON s.Sales_Order_Fill_Key = sof.Sales_Order_Fill_Key
	  LEFT JOIN [CWC_DW].[Fact].[Trade_Agreement_Costs] tc ON s.Sales_Line_Product_Key = tc.Product_Key AND CAST(s.[Sales_Line_Created_Date] AS DATE) BETWEEN tc.[Start_Date] AND tc.[End_Date] AND tc.is_Removed_From_Source = 0
	  LEFT JOIN [CWC_DW].[Fact].[Trade_Agreement_Prices] tp ON s.Sales_Line_Product_Key = tp.Product_Key AND CAST(s.[Sales_Line_Created_Date] AS DATE) BETWEEN tp.[Start_Date] AND tp.[End_Date] AND tp.is_Removed_From_Source = 0
	  LEFT JOIN [Invoices] i ON i.Sales_Key = s.Sales_Key
	  LEFT JOIN [CWC_DW].[Dimension].[Locations] L ON s.Sales_Header_Location_Key = l.Location_Key
	  --LEFT JOIN [CWC_DW].[Power_BI].[v_Fact_Inventory_Current] inv ON p.Product_Key = inv.Product_Key AND inv.[Inventory Warehouse] = 'Distribution Center'
	  --LEFT JOIN [CWC_DW].[Dimension].[Employees] (NOLOCK) e ON s.Sales_Line_Employee_Key = e.Employee_Key
WHERE --CAST(s.[Sales_Line_Created_Date_EST] AS DATE) >= '12/1/2020'
	   (Fiscal_Year BETWEEN DATEPART(YEAR,CAST(GETDATE() AS DATE))-1 AND DATEPART(YEAR,CAST(GETDATE() AS DATE)))
	  
	  --(
		 --    (DATEPART(YEAR,CAST(GETDATE() AS DATE)) <> 2022 AND (Fiscal_Year BETWEEN DATEPART(YEAR,CAST(GETDATE() AS DATE))-1 AND DATEPART(YEAR,CAST(GETDATE() AS DATE)))) --Current and Previous Year
		 -- OR (DATEPART(YEAR,CAST(GETDATE() AS DATE)) = 2022 AND (Fiscal_Year BETWEEN DATEPART(YEAR,CAST(GETDATE() AS DATE))-3 AND DATEPART(YEAR,CAST(GETDATE() AS DATE)) AND Fiscal_Year <> 2020)) -- Current. Previous and 2019 just for FY 2022
	  --)
	
	--AND p.[Item_ID] NOT IN ('CreditOnly','00001')
	--AND iw.[Inventory_Warehouse] = 'Distribution Center'
	--AND CAST(Sales_Line_Created_Date_EST AS DATE) = '11/23/2021'
	
	--AND p.Item_ID = '13262'
	--AND p.Item_ID = '20791'
	--AND p.Color_ID = '0271'
	--AND p.Size_ID = '930'
	--AND s.Sales_Key = 13505493
;
