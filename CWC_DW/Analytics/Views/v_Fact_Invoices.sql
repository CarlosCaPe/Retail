


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Analytics].[v_Fact_Invoices]

AS

WITH Invoice_Cost AS
(
SELECT
s.Sales_Key
,Invoice_Cost_Price = SUM(s.Sales_Line_Cost_Price)
FROM [CWC_DW].[Fact].[Sales] s
INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes] (NOLOCK) soa ON s.[Sales_Order_Attribute_Key] = soa.[Sales_Order_Attribute_Key]
INNER JOIN [CWC_DW].[Fact].[Invoices] (NOLOCK) i ON s.Sales_Key = i.Sales_Key 
WHERE [Order_Classification] IN ('Return','Sale') AND s.is_Removed_From_Source = 0 AND i.is_Removed_From_Source = 0
GROUP BY s.Sales_Key
)
,Sales AS
(
SELECT
       s.Sales_Key
	  ,[Sales_Line_Create_Date_Key] = d.Date_Key
      ,[Sales_Header_Customer_Key]
      ,[Sales_Header_Property_Key]
      ,[Sales_Line_Property_Key]
      ,[Sales_Line_Product_Key]
	  ,[Sales_Header_Location_Key]
      ,[Shipping_Inventory_Warehouse_Key] = CAST([Shipping_Inventory_Warehouse_Key] AS SMALLINT)
      ,[Sales_Line_Employee_Key]
      ,s.[Sales_Order_Attribute_Key]
	  ,Invoice_Cost_Price
	  ,Seq = ROW_NUMBER() OVER(PARTITION BY s.Sales_Key ORDER BY s.[Sales_Line_Created_Date])
FROM [CWC_DW].[Fact].[Sales] s
INNER JOIN Invoice_Cost ic ON s.Sales_Key = ic.Sales_Key
INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes] (NOLOCK) soa ON s.[Sales_Order_Attribute_Key] = soa.[Sales_Order_Attribute_Key]
INNER JOIN [CWC_DW].[Fact].[Invoices] (NOLOCK) i ON s.Sales_Key = i.Sales_Key
LEFT JOIN [CWC_DW].[Dimension].[Dates] (NOLOCK) d ON s.[Sales_Line_Created_Date] = d.[Calendar_Date]
WHERE [Order_Classification] IN ('Return','Sale') AND s.is_Removed_From_Source = 0 
) --SELECT * FROM Sales WHERE Sales_Key = 16055


SELECT [Invoice_Key]
      ,[Invoice_Number]
      ,[Invoice_Line_Number]
      ,i.[Sales_Key]
	  ,[Invoice_Line_Date_Key] = dil.Date_Key
	  ,[Invoice_Line_Delivery_Date_Key] = dd.Date_Key
      ,[Sales_Order_Number]
      --,[Invent_Trans_ID]
      ,[Invoice_Line_Product_Key]
      --,[Invoice_Line_Product_Number]
      ,[Invoice_Customer_Key]
      --,[Invoice_Customer_Account_Number]
      ,[Invoice_Property_Key]
      ,[Invoice_Header_Date]
      ,[Invoice_Line_Date]
      ,[Invoice_Line_Confirmed_Shipping_Date]
      ,[Invoice_Line_Delivery_Date]
      ,[Invoice_Line_Quantity]
      ,[Invoice_Line_Sales_Price]
      ,[Invoice_Line_Amount]
      ,[Invoice_Line_Tax_Amount]
      ,[Invoice_Line_Charge_Amount]
      ,[Invoice_Line_Discount_Amount]
	  ,[Invoice_Cost_Price]
	  ,[Sales_Line_Create_Date_Key]
      ,[Sales_Header_Customer_Key]
      ,[Sales_Header_Property_Key]
      ,[Sales_Line_Property_Key]
      ,[Sales_Line_Product_Key]
	  ,[Sales_Header_Location_Key]
      ,[Shipping_Inventory_Warehouse_Key]
      ,[Sales_Line_Employee_Key]
      ,[Sales_Order_Attribute_Key]
      --,[is_Removed_From_Source]
      --,[is_Excluded]
      --,[ETL_Created_Date]
      --,[ETL_Modified_Date]
      --,[ETL_Modified_Count]
  FROM [CWC_DW].[Fact].[Invoices] (NOLOCK) i
  LEFT JOIN [CWC_DW].[Dimension].[Dates] (NOLOCK) dil ON dil.Calendar_Date = CAST(i.[Invoice_Line_Date] AS DATE)
  LEFT JOIN [CWC_DW].[Dimension].[Dates] (NOLOCK) dd ON dd.Calendar_Date = CAST(i.[Invoice_Line_Delivery_Date] AS DATE)
  INNER JOIN Sales s ON i.Sales_Key = s.Sales_Key AND seq = 1
  AND i.is_Removed_From_Source = 0 ;

