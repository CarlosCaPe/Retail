



/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Analytics].[v_Fact_Sales]

AS

SELECT [Sales_Key]
      ,[Sales_Order_Number]
      ,[Sales_Line_Number]
      --,[Invent_Trans_ID]
      --,[Return_Invent_Trans_ID]
	  ,[Sales_Line_Create_Date_Key] = d.[Date_Key]
      ,[Sales_Header_Customer_Key]
      ,[Sales_Header_Property_Key]
      ,[Sales_Line_Property_Key]
      ,[Sales_Line_Product_Key]
	  ,[Sales_Header_Location_Key]
      ,[Shipping_Inventory_Warehouse_Key]
      ,[Sales_Line_Employee_Key]
      ,[Sales_Order_Attribute_Key] = CAST([Sales_Order_Attribute_Key] AS SMALLINT)
      --,[Sales_True_Return_Key]
      ,[Sales_Line_Amount]
      ,[Sales_Line_Discount_Amount]
      ,[Sales_Line_Cost_Price]
      ,[Sales_Line_Discount_Percentage]
      --,[Multi_Line_Discount_Code]
      --,[Multi_Line_Discount_Percentage]
      ,[Sales_Line_Reserve_Quantity]
      ,[Sales_Line_Ordered_Quantity]
      ,[Sales_Line_Price_Quantity]
      ,[Sales_Line_Remain_Sales_Physical]
      ,[Sales_Header_Modified_Date] = DATEADD(hh,-5,[Sales_Header_Modified_Date])
      ,[Sales_Header_Created_Date] = DATEADD(hh,-5,[Sales_Header_Created_Date])
      ,[Sales_Line_Modified_Date] = DATEADD(hh,-5,[Sales_Line_Modified_Date])
      ,[Sales_Line_Created_Date] = DATEADD(hh,-5,[Sales_Line_Created_Date])
      ,[Sales_Line_Confirmed_Date] = DATEADD(hh,-5,[Sales_Line_Confirmed_Date])
      ,[Sales_Line_Confirmed_Receipt_Date] = DATEADD(hh,-5,[Sales_Line_Confirmed_Receipt_Date])
      ,[Sales_Line_Requested_Receipt_Date] = DATEADD(hh,-5,[Sales_Line_Requested_Receipt_Date])
      ,[Sales_Line_Created_By]
      --,[is_Removed_From_Source]
      --,[is_Excluded]
      --,[ETL_Created_Date]
      --,[ETL_Modified_Date]
      --,[ETL_Modified_Count]
  FROM [CWC_DW].[Fact].[Sales] (NOLOCK) s
  LEFT JOIN [CWC_DW].[Dimension].[Dates] (NOLOCK) d ON d.Calendar_Date = CAST(DATEADD(hh,-5,s.[Sales_Line_Created_Date]) AS DATE)
  --AND is_Removed_From_Source = 0
  ;
