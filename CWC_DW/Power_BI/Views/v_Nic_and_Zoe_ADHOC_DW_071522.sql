


CREATE VIEW [Power_BI].[v_Nic_and_Zoe_ADHOC_DW_071522]

AS

WITH Invoices AS
(
SELECT
	 i.[Sales_Key]
	,[Invoice Number] = MIN(Invoice_Number)
	,[Invoice Count] = COUNT(i.Invoice_Key)
	,[Invoice_Date] = MIN(i.[Invoice_Line_Date])
	,[Invoice_Amount] = SUM(i.[Invoice_Line_Amount])
	,[Invoice_Quantity] = SUM(i.[Invoice_Line_Quantity])
	,[Invoice_Tax_Amount] = SUM(i.[Invoice_Line_Tax_Amount])
	,[Shipping Income] = SUM(i.Invoice_Header_Total_Charge_Amount)
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
	-- s.Sales_Key
	--,[Sales Date Est Key] = d.Date_Key
	--,[Product Key] = p.Product_Key
	 [Item] = p.Item_ID
	,[Color] = p.Color_ID
	,[Size] = p.Size_ID
	,p.SKU
	,[Item Name] = p.Item_Name_Standard
	,[Sales Order Number] = s.Sales_Order_Number
	,[Sales Line Number] = s.Sales_Line_Number
	--,[Sales_Line_Cost_Price] = s.Sales_Line_Cost_Price
	,[Sale Date] = Cast(s.[Sales_Line_Created_Date_est] AS DATE)
	,[Invoice Date] = i.Invoice_Date

	,[Sales Line Type] = slp.[Sales_Line_Type]
	,[Channel] = shp.Sales_Header_Retail_Channel
	,[Retail Channel] = shp.Sales_Header_Retail_Channel_Name
	,[Sales Header Status] = CASE shp.[Sales_Header_Status] WHEN 'Backorder' THEN 'Open' ELSE shp.[Sales_Header_Status] END
	,[Sales Line Status] = CASE slp.[Sales_Line_Status] WHEN 'Backorder' THEN 'Open' ELSE slp.[Sales_Line_Status] END
	--,[Sales Line Status Index] = CASE slp.[Sales_Line_Status] WHEN 'Backorder' THEN 1 WHEN 'Delivered' THEN 2 WHEN 'Invoiced' THEN 3 WHEN 'Canceled' THEN 4 END
	--,[Order Classification] = soa.[Order_Classification]
	,[Tax Group] = slp.Sales_Line_Tax_Group
	--,[Sales Amount] = s.[Sales_Line_Amount]
	,[Unit Amount] = s.Sales_Line_Ordered_Quantity * ISNULL(NULLIF(s.Sales_Line_Price,0),NULLIF(tp.Price,0))
	,[Unit Price Amount] = CASE WHEN slp.Sales_Line_Type = 'Sale' THEN s.Sales_Line_Ordered_Quantity * ISNULL(NULLIF(s.Sales_Line_Price,0),NULLIF(tp.Price,0)) ELSE NULL END

	--,[Gross Margin] = (ISNULL(i.Shipped_Amount,0) + CASE WHEN slp.Sales_Line_Type = 'Return' THEN ISNULL(s.Sales_Line_Amount,0) ELSE 0 END)
	--				- ((CASE WHEN i.Sales_Key IS NOT NULL THEN ([Sales_Line_Ordered_Quantity] * ISNULL(NULLIF(s.Sales_Line_Cost_Price,0),NULLIF(tc.Cost,0))) ELSE NULL END)
	--				+(ISNULL(CASE WHEN slp.Sales_Line_Type = 'Return' THEN ([Sales_Line_Ordered_Quantity] * ISNULL(NULLIF(s.Sales_Line_Cost_Price,0),NULLIF(tc.Cost,0))) ELSE NULL END,0)))

	,[Net Amount] = ISNULL(i.[Invoice_Amount],0) + CASE WHEN slp.Sales_Line_Type = 'Return' THEN ISNULL(s.Sales_Line_Amount,0) ELSE 0 END
	,[Net Units] = ISNULL(i.[Invoice_Amount],0) + CASE WHEN slp.Sales_Line_Type = 'Return' THEN ISNULL(s.Sales_Line_Ordered_Quantity,0) ELSE 0 END 
	--,[Landed Cost] = ((CASE WHEN i.Sales_Key IS NOT NULL THEN ([Sales_Line_Ordered_Quantity] * ISNULL(NULLIF(s.Sales_Line_Cost_Price,0),NULLIF(tc.Cost,0))) ELSE NULL END)
	--				+(ISNULL(CASE WHEN slp.Sales_Line_Type = 'Return' THEN ([Sales_Line_Ordered_Quantity] * ISNULL(NULLIF(s.Sales_Line_Cost_Price,0),NULLIF(tc.Cost,0))) ELSE NULL END,0)))
	,[Line Amount] = s.Sales_Line_Amount
	,[Sales Amount] = CASE WHEN slp.Sales_Line_Type = 'Sale' THEN s.Sales_Line_Amount ELSE NULL END --Gross Sales
	,[Sale Price] = CASE WHEN slp.Sales_Line_Type = 'Sale' THEN s.Sales_Line_Price ELSE NULL END
	,[Sales Discount Amount] = CASE WHEN slp.Sales_Line_Type = 'Sale' THEN s.Sales_Line_Discount_Amount ELSE NULL END
	,[Sales Units] = CASE WHEN slp.Sales_Line_Type = 'Sale' THEN s.Sales_Line_Ordered_Quantity ELSE NULL END 
	,[Sales Landed Cost] = CASE WHEN slp.Sales_Line_Type = 'Sale' THEN (s.[Sales_Line_Ordered_Quantity] * ISNULL(NULLIF(s.Sales_Line_Cost_Price,0),NULLIF(tc.Cost,0))) ELSE NULL END
	,[Sales Remain Sales Physical] = CASE WHEN slp.Sales_Line_Type = 'Sale' THEN s.[Sales_Line_Remain_Sales_Physical] ELSE NULL END
	,[Sales Cancel Amount] = CASE WHEN soa.[Order_Classification] = 'Canceled Sale' THEN s.Sales_Line_Amount ELSE NULL END  
	,[Sales Cancel Units] = CASE WHEN soa.[Order_Classification] = 'Canceled Sale' THEN s.Sales_Line_Ordered_Quantity ELSE NULL END

	,[Original Sales Date] = ro.Original_Sales_Date
	,[Original Sales Order Number] = ro.Original_Sales_Order_Number
	,[Original Sales Order Line Number] = ro.Original_Sales_Order_Line_Number
	--,[Original is Baked] = ro.Original_is_Baked
	--,[Baked Key] = CASE WHEN ro.Original_is_Baked > 0 OR i.Baked  > 0 THEN 1 ELSE 2 END -- If SO is baked or Original Sales Order to the return is baked

	,[Return Amount] = CASE WHEN slp.Sales_Line_Type = 'Return' THEN s.Sales_Line_Amount ELSE NULL END
	,[Return Discount Amount] = CASE WHEN slp.Sales_Line_Type = 'Return' THEN s.Sales_Line_Discount_Amount ELSE NULL END
	,[Return Units] = CASE WHEN slp.Sales_Line_Type = 'Return' THEN s.Sales_Line_Ordered_Quantity ELSE NULL END 
	,[Return Landed Cost] = CASE WHEN slp.Sales_Line_Type = 'Return' THEN (s.[Sales_Line_Ordered_Quantity] * ISNULL(NULLIF(s.Sales_Line_Cost_Price,0),NULLIF(tc.Cost,0))) ELSE NULL END
	,[Return Deposition Action] = CAST((CASE WHEN slp.Sales_Line_Type = 'Return' THEN ISNULL(slp.Sales_Line_Return_Deposition_Action,'{-Not Populated-}') ELSE NULL END) AS VARCHAR(100))
	,[Return Deposition Description] = CAST((CASE WHEN slp.Sales_Line_Type = 'Return' THEN ISNULL(slp.Sales_Line_Return_Deposition_Action,'{-Not Populated-}') ELSE NULL END) AS VARCHAR(100))
	,[Sales_Header_Return_Reason_Group] = CAST((CASE WHEN slp.Sales_Line_Type = 'Return' THEN ISNULL(shp.[Sales_Header_Return_Reason_Group],'{-Not Populated-}') ELSE NULL END) AS VARCHAR(100))
    ,[Sales Header Return Reason] = CAST((CASE WHEN slp.Sales_Line_Type = 'Return' THEN ISNULL(shp.[Sales_Header_Return_Reason],'{-Not Populated-}') ELSE NULL END) AS VARCHAR(100))
    ,[Sales Header Delivery Mode] = shp.[Sales_Header_Delivery_Mode]
    ,[Sales Header On Hold] = CASE ISNULL(shp.[Sales_Header_On_Hold],0) WHEN 0 THEN 'Not On Hold' ELSE 'On Hold' END

	,[Cancel Amount] = CASE WHEN soa.[Order_Classification] = 'Canceled Sale' THEN s.Sales_Line_Amount ELSE NULL END  
	,[Cancel Units] = CASE WHEN soa.[Order_Classification] = 'Canceled Sale' THEN s.Sales_Line_Ordered_Quantity ELSE NULL END

	,[Return Cancel Amount] = CASE WHEN soa.[Order_Classification] = 'Canceled Return' THEN s.Sales_Line_Amount ELSE NULL END  
	,[Return Cancel Units] = CASE WHEN soa.[Order_Classification] = 'Canceled Return' THEN s.Sales_Line_Ordered_Quantity ELSE NULL END

	,[Invoice Number] = i.[Invoice Number]
	,[Invoice Count] = i.[Invoice Count]
	,[Shipped Amount] = CASE WHEN slp.Sales_Line_Type = 'Sale' THEN i.[Invoice_Amount] ELSE NULL END
	,[Shipped Units] = CASE WHEN slp.Sales_Line_Type = 'Sale' THEN i.[Invoice_Quantity] ELSE NULL END --CASE WHEN slp.Sales_Line_Type = 'Return' THEN s.Sales_Line_Ordered_Quantity ELSE i.Shipped_Quantity END
	,[Shipped Tax Amount] = CASE WHEN slp.Sales_Line_Type = 'Sale' THEN i.[Invoice_Tax_Amount] ELSE NULL END
	,[Shipped Landed Cost] = CASE WHEN i.Sales_Key IS NOT NULL THEN ([Sales_Line_Ordered_Quantity] * ISNULL(NULLIF(s.Sales_Line_Cost_Price,0),NULLIF(tc.Cost,0))) ELSE NULL END--NULLIF((s.Extended_Sale_Cost,0) Extended Sale Cost
	,[Shipping Income] = NULLIF(i.[Shipping Income],0)

	,[Return Invoice Amount] = CASE WHEN slp.Sales_Line_Type = 'Return' THEN i.[Invoice_Amount] ELSE NULL END
	,[Return Invoice Units] = CASE WHEN slp.Sales_Line_Type = 'Return' THEN i.[Invoice_Quantity] ELSE NULL END 
	,[Return Invoice Tax Amount] = CASE WHEN slp.Sales_Line_Type = 'Return' THEN i.[Invoice_Tax_Amount] ELSE NULL END
	
	--,[Shipped Average Unit Retail] = CASE WHEN i.Sales_Key IS NOT NULL THEN i.Shipped_Amount/i.Shipped_Quantity ELSE NULL END
	--,tc.Cost
	--,tp.Price
	--,[Retail Price] = ISNULL(NULLIF(s.Sales_Line_Price,0),NULLIF(tp.Price,0))
	--,s.Sales_Line_Price
	--,[Cost Price] = ISNULL(NULLIF(s.Sales_Line_Cost_Price,0),NULLIF(tc.Cost,0))
	--,[Extended Cost Price] = ISNULL(NULLIF(s.Sales_Line_Cost_Price,0),NULLIF(tc.Cost,0)) * Sales_Line_Ordered_Quantity
	--,[Lot ID] = s.Invent_Trans_ID
	--,[Delivery Location Key] = s.Sales_Header_Location_Key
	--,[B2B Key] = CASE WHEN s.Sales_Header_Customer_Key IN (SELECT Customer_Key
	--		  FROM [CWC_DW].[Dimension].[Customers]
	--		  WHERE Customer_Group = 'Jobber'
	--		  OR Customer_Account = 'DC00240929') THEN 1 ELSE 2 END
	--,[Delivery Street] = l.Street
	--,[Delivery City] = l.City
	--,[Delivery State] = l.State
	--,[Delivery Zip Code] = l.Zip_Code
	
	--,[Fiscal Week Number] = CAST(d.Fiscal_Week_of_Year AS SMALLINT)
	--,[Fiscal Week Short] = d.[Fiscal_Week_of_Year_Name]

 --   ,[Fiscal Month Week] = d.[Fiscal_Month_Week_Name]
 --   ,[Fiscal Month Year Week] = d.[Fiscal_Month_Year_Week_Name]
 --   ,d.[Confirmed_Delivery_Week_Month_Year_Index]
	--,[Fiscal Month Number] = CAST(d.[Fiscal_Month] AS TINYINT)
 --   ,[Fiscal Month] = d.[Fiscal_Month_Name]
 --   ,d.[Fiscal_Month_Year_Index]
 --   ,[Fiscal Quarter] = d.[Fiscal_Quarter_Name]
 --   ,[Fiscal Quarter Year] = d.[Fiscal_Quarter_Year_Name]
 --   ,[Fiscal Year] = d.[Fiscal_Year]
 --   ,[Fiscal Year Name] = d.[Fiscal_Year_Name]
 --   ,[Fiscal Month Year] = d.[Fiscal_Month_Year]

 --   ,[Department] = ISNULL(p.[Department_Name],'{-No Department-}')
	--,[Class] = ISNULL(p.[Class_Name],'{-No Class-}')
	--,[Item ID] = p.[Item_ID]
	--,[Color ID] = p.[Color_ID]
	--,[Size ID] = p.[Size_ID]
	--,[Config ID] = p.[Style_ID]
	--,SKU = CONCAT(p.[Item_ID],p.[Color_ID],p.[Size_ID])
	
	--,[Item Number Name] = ISNULL(p.[Item_Number_Name],'{-No Item-}')
	--,[Item] = ISNULL(p.[Item_Name_Standard],'{-No Item-}')
	--,[Color] = ISNULL(p.[Color_Name],'{-No Color-}')
	--,[Size] = ISNULL(p.[Size_Name],'{-No Size-}')
	--,[Config] = ISNULL(p.Style_Name,'{-No Style-}')
	--,[Vendor] = ISNULL(p.Vendor_Name,'{-No Vendor-}')

	--,[Available On Hand Quantity (Available)] = CAST(inv.[Available On Hand Quantity (Available)] AS SMALLINT)
	--,[Available Ordered Quantity (Available)] = CAST(inv.[Available Ordered Quantity (Available)] AS SMALLINT)
	--,[On Order Quantity (Available)] = CAST(inv.[On Order Quantity (Available)] AS SMALLINT)
	--,[On Hand Quantity (Available)] = CAST(inv.[On Hand Quantity (Available)] AS SMALLINT)
	,[Customer Account] = c.Customer_Account
	,[First Name] = c.Person_First_Name
	,[Last Name] = c.Person_Last_Name
	,[Contact Phone] = c.Primary_Contact_Phone
	,[Contract Email] = c.Primary_Contact_Email
	,[Employee] = ISNULL(e.Employee_Full_Name,s.[Sales_Line_Created_By])
	,[License Source] = CASE WHEN s.[Sales_Line_Created_By] = 'Admin' THEN 'D365 Admin' WHEN s.[Sales_Line_Created_By] = 'dmsworkflow' THEN 'DMS Workflow' ELSE e.License_Source END
	,l.Street
	,l.State
	,l.City
	,l.Zip_Code
FROM [CWC_DW].[Fact].[Sales] (NOLOCK) s
	  LEFT JOIN Returns_Original ro ON s.Return_Invent_Trans_ID = ro.Invent_Trans_ID AND ro.Seq = 1
	  INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) d ON d.Calendar_Date = CAST(s.[Sales_Line_Created_Date_est] AS DATE)
	  INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes] (NOLOCK) soa ON s.[Sales_Order_Attribute_Key] = soa.[Sales_Order_Attribute_Key]
	  INNER JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON s.Sales_Line_Product_Key = p.[Product_Key]
	  INNER JOIN [CWC_DW].[Dimension].[Inventory_Warehouses] (NOLOCK) iw ON s.Shipping_Inventory_Warehouse_Key = iw.Inventory_Warehouse_Key
	  INNER JOIN [CWC_DW].[Dimension].[Sales_Line_Properties] (NOLOCK) slp ON s.Sales_Line_Property_Key = slp.Sales_Line_Property_Key
	  LEFT JOIN [CWC_DW].[Dimension].[Sales_Header_Properties] (NOLOCK) shp ON s.Sales_Header_Property_Key = shp.Sales_Header_Property_Key
	  LEFT JOIN [CWC_DW].[Dimension].[Sales_Order_Fill] (NOLOCK) sof ON s.Sales_Order_Fill_Key = sof.Sales_Order_Fill_Key
	  LEFT JOIN [CWC_DW].[Fact].[Trade_Agreement_Costs] tc ON s.Sales_Line_Product_Key = tc.Product_Key AND CAST(s.[Sales_Line_Created_Date] AS DATE) BETWEEN tc.[Start_Date] AND tc.[End_Date] AND tc.is_Removed_From_Source = 0
	  LEFT JOIN [CWC_DW].[Fact].[Trade_Agreement_Prices] tp ON s.Sales_Line_Product_Key = tp.Product_Key AND CAST(s.[Sales_Line_Created_Date] AS DATE) BETWEEN tp.[Start_Date] AND tp.[End_Date] AND tp.is_Removed_From_Source = 0
	  LEFT JOIN [Invoices] i ON i.Sales_Key = s.Sales_Key
	  LEFT JOIN [CWC_DW].[Dimension].[Locations] L ON s.Sales_Header_Location_Key = l.Location_Key
	  --LEFT JOIN [CWC_DW].[Power_BI].[v_Fact_Inventory_Current] inv ON p.Product_Key = inv.Product_Key AND inv.[Inventory Warehouse] = 'Distribution Center'
	  LEFT JOIN [CWC_DW].[Dimension].[Employees] (NOLOCK) e ON s.Sales_Line_Employee_Key = e.Employee_Key
	  LEFT JOIN [CWC_DW].[Dimension].[Customers] (NOLOCK) c ON s.Sales_Header_Customer_Key = c.Customer_Key
WHERE --CAST(s.[Sales_Line_Created_Date_EST] AS DATE) >= '12/1/2020'
	   (Fiscal_Year BETWEEN DATEPART(YEAR,CAST(GETDATE() AS DATE))-1 AND DATEPART(YEAR,CAST(GETDATE() AS DATE)))
	  
	  --(
		 --    (DATEPART(YEAR,CAST(GETDATE() AS DATE)) <> 2022 AND (Fiscal_Year BETWEEN DATEPART(YEAR,CAST(GETDATE() AS DATE))-1 AND DATEPART(YEAR,CAST(GETDATE() AS DATE)))) --Current and Previous Year
		 -- OR (DATEPART(YEAR,CAST(GETDATE() AS DATE)) = 2022 AND (Fiscal_Year BETWEEN DATEPART(YEAR,CAST(GETDATE() AS DATE))-3 AND DATEPART(YEAR,CAST(GETDATE() AS DATE)) AND Fiscal_Year <> 2020)) -- Current. Previous and 2019 just for FY 2022
	  --)
	
	--AND p.[Item_ID] NOT IN ('CreditOnly','00001')
	AND p.[Item_ID] IN ('21538','21814')
	--AND slp.[Sales_Line_Type] = 'Sale'
	--AND iw.[Inventory_Warehouse] = 'Distribution Center'
	--AND CAST(Sales_Line_Created_Date_EST AS DATE) = '11/23/2021'
	
	--AND p.Item_ID = '13262'
	--AND p.Item_ID = '20791'
	--AND p.Color_ID = '0271'
	--AND p.Size_ID = '930'
	--AND s.Sales_Key = 13505493
;


