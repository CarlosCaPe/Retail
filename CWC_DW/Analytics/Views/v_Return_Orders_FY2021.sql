
CREATE VIEW [Analytics].v_Return_Orders_FY2021 AS

SELECT
	  -- s.[Sales_Key]
       [Sales_Order_Number] = s.[Sales_Order_Number]
	  ,s.[Sales_Line_Number]
	  --,[Sales_Header_Created_Date] = DATEADD(hh,-5,s.[Sales_Header_Created_Date])
      ,[Sales_Line_Created_Date] = DATEADD(hh,-5,s.[Sales_Line_Created_Date])
	  ,[Original_Sales_Order_Number] = s2.Sales_Order_Number
	  ,[Original_Sales_Line_Number] = s2.[Sales_Line_Number]
	  --,[Original_Sales_Header_Created_Date] = DATEADD(hh,-5,s2.[Sales_Header_Created_Date])
      ,[Original_Sales_Line_Created_Date] = DATEADD(hh,-5,s2.[Sales_Line_Created_Date])
      
	  --,[Order_Classification]
	  ,shp.Sales_Header_Status
	  ,shp.Sales_Header_Type
	  ,slp.Sales_Line_Status
	  ,slp.Sales_Line_Type
	  ,p.Item_ID
	  ,p.Item_Name
	  ,p.Color_Name
	  ,p.Size_Name
	  ,p.Department_Name
	  ,p.Class_Name
      --,[Invent_Trans_ID]
      --,[Return_Invent_Trans_ID]
	  --,[Sales_Line_Create_Date_Key] = d.[Date_Key]
   --   ,[Sales_Header_Customer_Key]
   --   ,[Sales_Header_Property_Key]
   --   ,[Sales_Line_Property_Key]
   --   ,[Sales_Line_Product_Key]
	  --,[Sales_Header_Location_Key]
      --,[Shipping_Inventory_Warehouse_Key] = CAST([Shipping_Inventory_Warehouse_Key] AS SMALLINT)
      --,[Sales_Line_Employee_Key]
      --,[Sales_Order_Attribute_Key] = CAST(s.Sales_Order_Attribute_Key AS SMALLINT)
      ,[Sales_Line_Amount] = s.[Sales_Line_Amount] --* -1
      ,[Sales_Line_Discount_Amount] = s.[Sales_Line_Discount_Amount] --* -1
      --,[Sales_Line_Cost_Price]
      --,[Sales_Line_Discount_Percentage]
      --,[Multi_Line_Discount_Code]
      --,[Multi_Line_Discount_Percentage]
      --,[Sales_Line_Reserve_Quantity] = [Sales_Line_Reserve_Quantity] --* -1
      ,[Sales_Line_Ordered_Quantity] = s.[Sales_Line_Ordered_Quantity]-- * -1
      --,[Sales_Line_Price_Quantity] = [Sales_Line_Price_Quantity] --* -1
      ,s.[Sales_Line_Remain_Sales_Physical]
      --,[Sales_Header_Modified_Date] = DATEADD(hh,-5,[Sales_Header_Modified_Date])
	  
      
      --,[Sales_Line_Confirmed_Date] = DATEADD(hh,-5,[Sales_Line_Confirmed_Date])
      --,[Sales_Line_Confirmed_Receipt_Date] = DATEADD(hh,-5,Sales_Line_Confirmed_Receipt_Date)
      --,[Sales_Line_Requested_Receipt_Date] = DATEADD(hh,-5,Sales_Line_Requested_Receipt_Date)
	  ,Sales_Header_Return_Reason
	  ,Sales_Header_Return_Reason_Group
	  ,Sales_Line_Return_Deposition_Action
	  ,Sales_Line_Return_Deposition_Description

      ,s.[Sales_Line_Created_By]
	  --,i.Invoice_Key
	  --,i.Invoice_Property_Key
	  --,i.Invoice_Line_Delivery_Date_Key
	  --,i.Invoice_Line_Date_Key
      --,[is_Removed_From_Source]
      --,[is_Excluded]
      --,[ETL_Created_Date]
      --,[ETL_Modified_Date]
      --,[ETL_Modified_Count]
  FROM [CWC_DW].[Fact].[Sales] (NOLOCK) s
  INNER JOIN [CWC_DW].[Analytics].[v_Dim_Dates] (NOLOCK) d ON d.Calendar_Date = CAST(DATEADD(hh,-5,s.[Sales_Line_Created_Date]) AS DATE)
  INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes] (NOLOCK) soa ON s.[Sales_Order_Attribute_Key] = soa.[Sales_Order_Attribute_Key]
  INNER JOIN [CWC_DW].[Dimension].[Sales_Header_Properties] (NOLOCK) shp ON s.Sales_Header_Property_Key = shp.Sales_Header_Property_Key
  INNER JOIN [CWC_DW].[Dimension].[Sales_Line_Properties] (NOLOCK) slp ON s.Sales_Line_Property_Key = slp.Sales_Line_Property_Key
  INNER JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON s.Sales_Line_Product_Key = p.Product_Key
  LEFT JOIN [CWC_DW].[Fact].[Sales] (NOLOCK) s2 ON s.Return_Invent_Trans_ID = s2.Invent_Trans_ID
  --LEFT JOIN [Invoice] i ON i.Sales_Key = s.Sales_Key AND i.Seq = 1
  WHERE soa.[Order_Classification] = 'Return' AND Fiscal_Year = 2021;