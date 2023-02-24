




/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Power_BI].[v_Margin_Alert]

AS  
  
  SELECT --TOP 1000
	   [Sales Order Number] = s.Sales_Order_Number
	  ,[Sale Line Number] = s.Sales_Line_Number
	  ,[Customer Account] = [Customer_Account]
      ,[Customer Group] = [Customer_Group]
	  ,[Customer Full Name] = ISNULL([Person_First_Name],'') + ' ' + ISNULL([Person_Last_Name],'')
	  ,[Agent] = e.Employee_Full_Name
	  ,shp.Sales_Header_Retail_Channel
	  ,s.Sales_Line_Created_By
	  ,[Call Center] = ISNULL(e.License_Source,'Admin')
      ,[Sales_Line_Create_Date_Key] = d.[Date_Key]
	  ,[Sales Date] = CAST(DATEADD(hh,-5,s.[Sales_Line_Created_Date]) AS DATE)
      ,s.[Sales_Header_Customer_Key]
	  ,s.Sales_Margin_Key
	  ,[Sales Line Amount] = s.Sales_Line_Amount
	  ,[Sales Price] = s.Sales_Line_Price
	  ,[Sales Ordered Quantity] = s.Sales_Line_Ordered_Quantity
	  ,[Extended Sale Cost] = s.Extended_Sale_Cost--s.Sales_Line_Ordered_Quantity * s.Sales_Line_Cost_Price
	  ,[Extended Sale Amount] = s.Extended_Sale_Amount --s.Sales_Line_Ordered_Quantity * s.Sales_Line_Price
	  ,[Sales Discount Total] = s.Sales_Discount_Total--(s.Sales_Line_Ordered_Quantity * s.Sales_Line_Price) - s.Sales_Line_Amount
	  ,[Sales Margin]  = s.Sales_Margin --s.Sales_Line_Amount - (s.Sales_Line_Ordered_Quantity * s.Sales_Line_Cost_Price)
	  ,[Sales Margin Rate] = s.Sales_Margin_Rate--CASE WHEN (s.Sales_Line_Ordered_Quantity * s.Sales_Line_Cost_Price) <> 0 THEN  (s.Sales_Line_Amount - (s.Sales_Line_Ordered_Quantity * s.Sales_Line_Cost_Price))/(s.Sales_Line_Ordered_Quantity * s.Sales_Line_Cost_Price) ELSE 0 END
	  --,[Sales_Order_Fill] = sof.[Sales_Order_Fill]
   --   ,[Fill_Days] = sof.[Fill_Days]
	  ,s.[Sales_Line_Product_Key]
	  ,[Item Number] = [Item_ID]
      ,[Item] = [Item_Name]
	  ,[Item Number Name] = [Item_ID] + ' - ' + [Item_Name]
      ,[Color] = [Color_Name]
      ,[Size] = [Size_Name]
      ,[Style] = [Style_Name]
	  --,[Active Product] = CASE is_Active_Product WHEN 1 THEN 'Active Product' ELSE 'Not Active Product' END
	  
      --,[Person_First_Name] --
      --,[Person_Last_Name] --
	  
	  --,es.Sales_Line_Number



  FROM [CWC_DW].[Fact].[Sales] (NOLOCK) s
	  INNER JOIN [CWC_DW].[Dimension].[Dates] (NOLOCK) d ON d.Calendar_Date = CAST(s.[Sales_Line_Created_Date_EST] AS DATE)
	  INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes] (NOLOCK) soa ON s.[Sales_Order_Attribute_Key] = soa.[Sales_Order_Attribute_Key]
	  LEFT JOIN [CWC_DW].[Fact].[Invoices] (NOLOCK) i ON i.Sales_Key = s.Sales_Key --AND i.Seq = 1
	  LEFT JOIN [CWC_DW].[Dimension].[Sales_Line_Properties] (NOLOCK) slp ON s.Sales_Line_Property_Key = slp.Sales_Line_Property_Key
	  LEFT JOIN [CWC_DW].[Dimension].[Sales_Header_Properties] (NOLOCK) shp ON s.Sales_Header_Property_Key = shp.Sales_Header_Property_Key
	  LEFT JOIN [CWC_DW].[Dimension].[Sales_Order_Fill] (NOLOCK) sof ON s.Sales_Order_Fill_Key = sof.Sales_Order_Fill_Key
	  LEFT JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON s.Sales_Line_Product_Key = p.Product_Key
	  LEFT JOIN [CWC_DW].[Dimension].[Customers] (NOLOCK) c ON s.[Sales_Header_Customer_Key] = c.Customer_Key
	  LEFT JOIN [CWC_DW].[Fact].[Sales] (NOLOCK) es ON es.Sales_Key = p.Earliest_Open_Sales_Key
	  LEFT JOIN [CWC_DW].[Dimension].[Employees] (NOLOCK) e ON s.Sales_Line_Employee_Key = e.Employee_Key
  WHERE soa.[Order_Classification] = 'Sale'
 -- AND sof.[Sales_Order_Fill] IN ('Partial Fill','No Fill')
  AND (CAST(DATEADD(hh,-5,s.[Sales_Line_Created_Date]) AS DATE) >= '12/1/2020')
  AND (shp.Sales_Header_Status <> 'Canceled' AND slp.Sales_Line_Status <> 'Canceled')
  AND (e.Employee_Key IS NOT NULL OR s.Sales_Line_Created_By = 'Admin')
  AND ((s.Sales_Line_Ordered_Quantity * s.Sales_Line_Price) <> s.Sales_Line_Amount) --sl.ExtSaleAmt != sl.LineAmount
  AND (s.Sales_Line_Cost_Price > 0)
  AND (s.Sales_Line_Ordered_Quantity > 0)
  --AND s.Sales_Order_Number IN ('E05785863','E05838265','E05834332')
  --AND (CASE WHEN (s.Sales_Line_Ordered_Quantity * s.Sales_Line_Cost_Price) <> 0 
		--   THEN  (s.Sales_Line_Amount - (s.Sales_Line_Ordered_Quantity * s.Sales_Line_Cost_Price))/(s.Sales_Line_Ordered_Quantity * s.Sales_Line_Cost_Price) 
	 -- ELSE 0 END * 100 <= 10)
  
  ;
