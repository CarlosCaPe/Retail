




/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Power_BI].[v_Fact_Sales_Sales_With_Cancels]

AS


SELECT --TOP 1000
	   s.[Sales_Key]
      ,s.[Sales_Order_Number]
	  ,s.Sales_Line_Number
	  ,s.Invent_Trans_ID
	  --,shp.[Sales_Header_Type]
   --   ,shp.[Sales_Header_Status]
   --   ,shp.[Sales_Header_Retail_Channel]
      --,shp.[Sales_Header_Return_Reason_Group]
      --,shp.[Sales_Header_Return_Reason]
      --,shp.[Sales_Header_Delivery_Mode]

	  ,[Sales_Line_Created_Date] = s.[Sales_Line_Created_Date_est]
	  ,[Sales_Header_Created_Date] = s.Sales_Header_Created_Date
	  --,[Sales_Line_Status] = CASE slp.[Sales_Line_Status] WHEN 'Backorder' THEN 'Open' ELSE slp.[Sales_Line_Status] END
      --,slp.[Sales_Line_Type]
      --,slp.[Sales_Line_Tax_Group]
      --,slp.[Sales_Line_Unit]
      --,slp.[Sales_Line_Return_Deposition_Action]
      --,slp.[Sales_Line_Return_Deposition_Description]

	  ,s.[Sales_Line_Product_Key]
	  ,s.[Sales_Header_Customer_Key]
	  --,s.[Sales_Order_Attribute_Key]
	  ,s.Sales_Line_Property_Key
	  ,s.Sales_Line_Employee_Key
	  ,s.Sales_Header_Property_Key
	  ,[Sales_Line_Create_Date_Key] = d.[Date_Key]


	  ,s.[Sales_Line_Ordered_Quantity]
	  ,s.[Sales_Line_Amount]
      ,s.[Sales_Line_Discount_Amount]
	  ,s.[Sales_Line_Cost_Price]
	  ,s.[Sales_Line_Remain_Sales_Physical]

      --,[Sales_Line_Number]
      --,[Invent_Trans_ID]
      --,[Return_Invent_Trans_ID]
	  
	  ,[Order_Classification]
      ,[Future_Return]
      
	  ,[Days_Open] = DATEDIFF(DAY,s.[Sales_Line_Created_Date_est],GETDATE())
	  ,[Sales_Order_Fill] = sof.[Sales_Order_Fill]
      ,[Fill_Days] = sof.[Fill_Days]
	  ,sof.[Fill_Days_Index]
      ,sof.[Sales_Order_Days]
      ,sof.[Sales_Order_Days_Index]

	  
	  --,[Item_Number] = [Item_ID]
   --   ,[Item] = [Item_Name]
	  --,[Item_Number_Name] = [Item_ID] + ' - ' + [Item_Name]
   --   ,[Color] = [Color_Name]
   --   ,[Size] = [Size_Name]
   --   ,[Style] = [Style_Name]
	  --,[Active_Product] = CASE is_Active_Product WHEN 1 THEN 'Active Product' ELSE 'Not Active Product' END
	  --,[Customer_Account] --
   --   ,[Customer_Group]
      --,[Person_First_Name] --
      --,[Person_Last_Name] --
	  --,[Customer_Full_Name] = ISNULL([Person_First_Name],'') + ' ' + ISNULL([Person_Last_Name],'')
	  --,es.Sales_Line_Number
	  --,Sales_Line_Created_Date = CAST(DATEADD(hh,-5,es.[Sales_Line_Created_Date]) AS DATE)
	  --,es.Sales_Line_Ordered_Quantity
	  --,es.Sales_Line_Amount
	  --,sof.[Fill_Days_Index]
   --   ,sof.[Sales_Order_Days]
   --   ,sof.[Sales_Order_Days_Index]
		,is_Canceled = CAST(CASE WHEN s.is_Removed_From_Source = 1 OR slp.Sales_Line_Status = 'Canceled' OR shp.Sales_Header_Status = 'Canceled' THEN 1 ELSE 0 END AS BIT)

  FROM [CWC_DW].[Fact].[Sales] (NOLOCK) s
	  INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) d ON d.Calendar_Date = CAST(s.[Sales_Line_Created_Date_est] AS DATE)
	  INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes] (NOLOCK) soa ON s.[Sales_Order_Attribute_Key] = soa.[Sales_Order_Attribute_Key]
	  --LEFT JOIN [CWC_DW].[Fact].[Invoices] i ON i.Sales_Key = s.Sales_Key --AND i.Seq = 1
	  LEFT JOIN [CWC_DW].[Dimension].[Sales_Line_Properties] (NOLOCK) slp ON s.Sales_Line_Property_Key = slp.Sales_Line_Property_Key
	  LEFT JOIN [CWC_DW].[Dimension].[Sales_Header_Properties] (NOLOCK) shp ON s.Sales_Header_Property_Key = shp.Sales_Header_Property_Key
	  LEFT JOIN [CWC_DW].[Dimension].[Sales_Order_Fill] (NOLOCK) sof ON s.Sales_Order_Fill_Key = sof.Sales_Order_Fill_Key
	  LEFT JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON s.Sales_Line_Product_Key = p.Product_Key
	  --LEFT JOIN [CWC_DW].[Dimension].[Customers] (NOLOCK) c ON s.[Sales_Header_Customer_Key] = c.Customer_Key
	  LEFT JOIN [CWC_DW].[Fact].[Sales] (NOLOCK) es ON es.Sales_Key = p.Earliest_Open_Sales_Key
	  --LEFT JOIN [CWC_DW].
  WHERE slp.Sales_Line_Type = 'Sale'
 -- AND sof.[Sales_Order_Fill] IN ('Partial Fill','No Fill')
  AND CAST(s.[Sales_Line_Created_Date_est] AS DATE) >= '12/1/2020'
  --AND (shp.Sales_Header_Status <> 'Canceled' AND slp.Sales_Line_Status <> 'Canceled')
 -- AND s.[Sales_Line_Amount] > 0
  --ORDER BY DATEADD(hh,-5,s.[Sales_Line_Created_Date]) ASC
  --AND s.is_Removed_From_Source = 0
  ;
