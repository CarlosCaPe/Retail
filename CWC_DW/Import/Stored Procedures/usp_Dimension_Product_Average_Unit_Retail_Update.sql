
CREATE PROC [Import].[usp_Dimension_Product_Average_Unit_Retail_Update]

AS

WITH AUR AS
(
SELECT
   [Product_Key] = s.Sales_Line_Product_Key
  --,[Total_Sales_Line_Amount] = SUM([Sales_Line_Amount])
  --,[Total_Sales_Line_Price] = SUM(s.Sales_Line_Price)
  --,[Total_Sales_Line_Ordered_Quantity] = SUM([Sales_Line_Ordered_Quantity])
  --,[Average_Unit_Retail] = CASE WHEN SUM([Sales_Line_Ordered_Quantity]) = 0 THEN NULL ELSE SUM([Sales_Line_Amount])/SUM([Sales_Line_Ordered_Quantity]) END
  ,[Average_Unit_Retail_Price] = CASE WHEN SUM([Sales_Line_Ordered_Quantity]) = 0 THEN NULL ELSE SUM(ISNULL(s.[Sales_Line_Price],p.[Trade_Agreement_Price]))/SUM([Sales_Line_Ordered_Quantity]) END
  FROM [CWC_DW].[Fact].[Sales] (NOLOCK) s
  INNER JOIN [CWC_DW].[Dimension].[Products] p ON s.Sales_Line_Product_Key = p.Product_Key
  INNER JOIN [CWC_DW].[Dimension].[Dates] (NOLOCK) d ON d.Calendar_Date = CAST(Sales_Line_Created_Date_EST AS DATE)
  INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes] (NOLOCK) soa ON s.[Sales_Order_Attribute_Key] = soa.[Sales_Order_Attribute_Key]
  --LEFT JOIN [CWC_DW].[Fact].[Invoices] i ON i.Sales_Key = s.Sales_Key --AND i.Seq = 1
  WHERE soa.[Order_Classification] = 'Sale'
  AND s.is_Removed_From_Source = 0 --AND i.is_Removed_From_Source = 0
  GROUP BY s.Sales_Line_Product_Key
  ) --SELECT * FROM AUR WHERE Product_Key IN (184074,184070)

  UPDATE p
  SET p.[Average_Unit_Retail] = aur.[Average_Unit_Retail_Price]
  FROM [CWC_DW].[Dimension].[Products] (NOLOCK) p
  LEFT JOIN AUR ON p.Product_Key = aur.Product_Key
  WHERE ISNULL(p.[Average_Unit_Retail],0) <> ISNULL(aur.[Average_Unit_Retail_Price],0);

