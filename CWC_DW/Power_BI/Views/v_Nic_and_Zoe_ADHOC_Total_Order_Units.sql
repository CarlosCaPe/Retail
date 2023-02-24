CREATE VIEW [Power_BI].[v_Nic_and_Zoe_ADHOC_Total_Order_Units] AS

SELECT [Sales Order Number] = Sales_Order_Number,Units = SUM(Sales_Line_Ordered_Quantity),[Line Count] = COUNT(*)
FROM Fact.Sales
WHERE Sales_Order_Number IN
(
SELECT DISTINCT Sales_Order_Number
FROM [CWC_DW].[Fact].[Sales] (NOLOCK) s
	  INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) d ON d.Calendar_Date = CAST(s.[Sales_Line_Created_Date_est] AS DATE)
	  INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes] (NOLOCK) soa ON s.[Sales_Order_Attribute_Key] = soa.[Sales_Order_Attribute_Key]
	  INNER JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON s.Sales_Line_Product_Key = p.[Product_Key]
WHERE p.[Item_ID] IN ('21538','21814')
)
GROUP BY Sales_Order_Number;