



/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Power_BI].[v_Sales_Order_Aging]

AS



SELECT --TOP 1000
	   s.[Sales_Key]
      ,s.[Sales_Order_Number]
	  ,[Sales Line Number] = s.Sales_Line_Number
	  ,s.[Sales_Line_Ordered_Quantity]
	  ,s.[Sales_Line_Amount]
      ,s.[Sales_Line_Discount_Amount]
	  ,[Sales_Line_Status] = CASE slp.[Sales_Line_Status] WHEN 'Backorder' THEN 'Open' ELSE slp.[Sales_Line_Status] END
      ,slp.[Sales_Line_Type]
	  ,Days_Open = DATEDIFF(DAY,DATEADD(hh,-5,s.[Sales_Line_Created_Date]),GETDATE())

	  --,shp.[Sales_Header_Type]
   --   ,shp.[Sales_Header_Status]
      ,shp.[Sales_Header_Retail_Channel]
      --,shp.[Sales_Header_Return_Reason_Group]
      --,shp.[Sales_Header_Return_Reason]
      ,shp.[Sales_Header_Delivery_Mode]
      --,[Sales_Line_Number]
      --,[Invent_Trans_ID]
      --,[Return_Invent_Trans_ID]
	  ,[Sales_Line_Create_Date_Key] = d.[Date_Key]
	  ,[Sales_Line_Created_Date] = CAST(DATEADD(hh,-5,s.[Sales_Line_Created_Date]) AS DATE)
      ,s.[Sales_Header_Customer_Key]
	  ,[Sales_Order_Fill] = sof.[Sales_Order_Fill]
      ,[Fill_Days] = sof.[Fill_Days]
	  ,s.[Sales_Line_Product_Key]
	  ,[Item_Number] = [Item_ID]
      ,[Item] = [Item_Name]
	  ,[Item_Number_Name] = [Item_ID] + ' - ' + [Item_Name]
      ,[Color] = [Color_Name]
      ,[Size] = [Size_Name]
      ,[Style] = [Style_Name]
	  ,[Active_Product] = CASE is_Active_Product WHEN 1 THEN 'Active Product' ELSE 'Not Active Product' END
	  ,[Customer_Account] --
      ,[Customer_Group]
      --,[Person_First_Name] --
      --,[Person_Last_Name] --
	  ,[Customer_Full_Name] = ISNULL([Person_First_Name],'') + ' ' + ISNULL([Person_Last_Name],'')
	  --,es.Sales_Line_Number
	  --,Sales_Line_Created_Date = CAST(DATEADD(hh,-5,es.[Sales_Line_Created_Date]) AS DATE)
	  --,es.Sales_Line_Ordered_Quantity
	  --,es.Sales_Line_Amount
	  ,sof.[Fill_Days_Index]
      ,sof.[Sales_Order_Days]
      ,sof.[Sales_Order_Days_Index]
	  ,[On Hold] = CASE ISNULL(shp.Sales_Header_On_Hold,0) WHEN 0 THEN 'No'ELSE 'Yes' END
	  ,[CC Auth Status] = CAST(ISNULL(CAST(cca.Authorization_Status AS VARCHAR(30)),'No Declines') AS VARCHAR(30))
	  ,[Decline Count] = ISNULL(Decline_Count,0)
	  ,[Success Count] = ISNULL(Success_Count,0)
	  ,[Lot ID] = s.Invent_Trans_ID
  FROM [CWC_DW].[Fact].[Sales] (NOLOCK) s
	  INNER JOIN [CWC_DW].[Dimension].[Dates] (NOLOCK) d ON d.Calendar_Date = CAST(DATEADD(hh,-5,s.[Sales_Line_Created_Date]) AS DATE)
	  INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes] (NOLOCK) soa ON s.[Sales_Order_Attribute_Key] = soa.[Sales_Order_Attribute_Key]
	  LEFT JOIN [CWC_DW].[Fact].[Invoices] i ON i.Sales_Key = s.Sales_Key --AND i.Seq = 1
	  LEFT JOIN [CWC_DW].[Dimension].[Sales_Line_Properties] (NOLOCK) slp ON s.Sales_Line_Property_Key = slp.Sales_Line_Property_Key
	  LEFT JOIN [CWC_DW].[Dimension].[Sales_Header_Properties] (NOLOCK) shp ON s.Sales_Header_Property_Key = shp.Sales_Header_Property_Key
	  LEFT JOIN [CWC_DW].[Dimension].[Sales_Order_Fill] (NOLOCK) sof ON s.Sales_Order_Fill_Key = sof.Sales_Order_Fill_Key
	  LEFT JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON s.Sales_Line_Product_Key = p.Product_Key
	  LEFT JOIN [CWC_DW].[Dimension].[Customers] (NOLOCK) c ON s.[Sales_Header_Customer_Key] = c.Customer_Key
	  LEFT JOIN [CWC_DW].[Fact].[Sales] (NOLOCK) es ON es.Sales_Key = p.Earliest_Open_Sales_Key
	  LEFT JOIN [CWC_DW].[Fact].[Credit_Card_Declines] (NOLOCK) ccd ON s.[Sales_Order_Number] = ccd.Sales_Order_Number
	  LEFT JOIN [CWC_DW].[Dimension].[Credit_Card_Authorizations] (NOLOCK) cca ON ccd.Credit_Card_Authorization_Key = cca.Credit_Card_Authorization_Key
  WHERE soa.[Order_Classification] = 'Sale'
 -- AND sof.[Sales_Order_Fill] IN ('Partial Fill','No Fill')
  AND CAST(DATEADD(hh,-5,s.[Sales_Line_Created_Date]) AS DATE) >= '12/1/2020'
  AND (shp.Sales_Header_Status <> 'Canceled' AND slp.Sales_Line_Status <> 'Canceled')
  AND s.is_Removed_From_Source = 0
 -- AND s.[Sales_Line_Amount] > 0
  --ORDER BY DATEADD(hh,-5,s.[Sales_Line_Created_Date]) ASC
  ;
  --Where is the On_Hold_Status field?

