

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Adhoc].[Return_Orders_FY2021]
AS


    SELECT--TOP (1000) 
	--r.[Sales_Key]
       [Return_Order_Number] = r.[Sales_Order_Number]
      ,[Return_Line_Number] = r.[Sales_Line_Number]
      --,[Sales_Line_Create_Date_Key]
      --,[Sales_Header_Customer_Key]
      --,[Sales_Header_Property_Key]
      --,[Sales_Line_Property_Key]
      --,[Sales_Line_Product_Key]
      --,[Sales_Header_Location_Key]
      --,[Shipping_Inventory_Warehouse_Key]
      --,[Sales_Line_Employee_Key]
      --,[Sales_Attributes_Key]
      ,[Return_Amount] = r.[Sales_Line_Amount]
      ,[Return_Discount] = r.[Sales_Line_Discount_Amount]
      ,[Return_Quantity] = r.[Sales_Line_Ordered_Quantity]

      ,[Return_Date] = CAST(r.[Sales_Line_Created_Date] AS DATE)
	  ,[Original_Sale_Date] = CAST(s.Sales_Line_Created_Date AS DATE)
	  ,[Original_Sale_Order_Number] = s.Sales_Order_Number
      --,[Sales_Line_Created_By]
	  ,lp.Sales_Line_Status
	  ,lp.Sales_Line_Type
	  ,lp.Sales_Line_Return_Deposition_Action
	  ,lp.Sales_Line_Return_Deposition_Description
	  ,[Invoice_Number]
	  ,[Invoice_Date] = Invoice_Line_Date
	  ,[Invoice_Line_Amount]
	  ,[Invoice_Line_Tax_Amount] 
  FROM [CWC_DW].[Fact].[Sales] r
  LEFT JOIN [CWC_DW].[Fact].[Sales] s ON r.Return_Invent_Trans_ID = s.Invent_Trans_ID
  LEFT JOIN [CWC_DW].[Analytics].[v_Dim_Sales_Header_Properties] hp ON r.[Sales_Header_Property_Key] = hp.[Sales_Header_Property_Key]
  LEFT JOIN [CWC_DW].[Analytics].[v_Dim_Sales_Line_Properties] lp ON r.[Sales_Line_Property_Key] = lp.[Sales_Line_Property_Key]
  INNER JOIN [CWC_DW].[Dimension].[Dates] (NOLOCK) d ON CAST(r.Sales_Line_Created_Date AS DATE) = d.Calendar_Date
  LEFT JOIN [CWC_DW].[Fact].[Invoices] (NOLOCK) i ON i.Sales_Key = r.Sales_Key
  WHERE Sales_Line_Type = 'Return' AND Sales_Line_Status <> 'Canceled'
  AND d.Fiscal_Year = 2021;
