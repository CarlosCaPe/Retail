
CREATE PROC [Import].[usp_Dimension_Product_Average_Unit_Cost_Update]

AS


WITH Invoices AS
(
SELECT
	 i.[Sales_Key]
	,[Invoice_Number] = MIN(Invoice_Number)
	,[Invoice_Count] = COUNT(i.Invoice_Key)
	,[Invoice_Date] = MIN(i.[Invoice_Line_Date])
	,[Invoice_Amount] = SUM(i.[Invoice_Line_Amount])
	,[Invoice_Quantity] = SUM(i.[Invoice_Line_Quantity])
	,[Invoice_Tax_Amount] = SUM(i.[Invoice_Line_Tax_Amount])
	
	,[Baked] = SUM(CAST(ia.is_Baked AS TINYINT))
FROM [CWC_DW].[Fact].[Invoices] (NOLOCK) i
	INNER JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON i.[Invoice_Line_Product_Key] = p.[Product_Key]
	INNER JOIN [CWC_DW].[Dimension].[Invoice_Attributes] (NOLOCK) ia ON i.Invoice_Attribute_Key = ia.Invoice_Attribute_Key
--WHERE i.[Invoice_Line_Quantity] > 0
--	AND i.[Invoice_Line_Date] >= '12/01/2020'
--	AND p.[Item_ID] NOT IN ('CreditOnly')
GROUP BY i.[Sales_Key]
)
,AUC_Details AS
(
SELECT
	   s.[Sales_Key]
	  ,slp.Sales_Line_Type
	  ,slp.Sales_Line_Status
	  ,soa.Order_Classification
	  ,[Product_Key] = s.Sales_Line_Product_Key
	  --,[Shipped_Landed_Cost] = ISNULL(NULLIF(s.Sales_Line_Cost_Price,0),NULLIF(tc.Cost,0)) * [Invoice_Quantity]
	  ,Cost = NULLIF(tc.Cost,0)
	  ,[Invoice_Quantity]
	  --,[Return_Landed_Cost] = CASE WHEN slp.Sales_Line_Type = 'Return' THEN (s.[Sales_Line_Ordered_Quantity] * ISNULL(NULLIF(s.Sales_Line_Cost_Price,0),NULLIF(tc.Cost,0))) ELSE NULL END
	  
	  ,s.[Sales_Line_Ordered_Quantity]
	  ,Sales_Line_Cost_Price = NULLIF(s.Sales_Line_Cost_Price,0)
	  ,[Shipped_Quantity] = i.[Invoice_Quantity]
	  ,s.[Sales_Line_Amount]
	  ,[Total_Sales_Line_Amount] = s.[Sales_Line_Amount]
	  ,[Total_Sales_Line_Ordered_Quantity] = s.[Sales_Line_Ordered_Quantity]
	  ,[Return_Units] = CASE WHEN slp.[Sales_Line_Type] = 'Return' THEN s.[Sales_Line_Ordered_Quantity] ELSE NULL END
	  ,[Return_Landed_Cost] = CASE WHEN slp.Sales_Line_Type = 'Return' THEN (s.[Sales_Line_Ordered_Quantity] * ISNULL(NULLIF(s.Sales_Line_Cost_Price,0),NULLIF(tc.Cost,0))) ELSE NULL END
	  ,[Shipped_Landed_Cost] = ISNULL(NULLIF(s.Sales_Line_Cost_Price,0),NULLIF(tc.Cost,0)) * i.[Invoice_Quantity]
	  --,[Average_Unit_Retail] = CASE WHEN s.[Sales_Line_Ordered_Quantity] = 0 THEN NULL ELSE s.[Sales_Line_Amount]/s.[Sales_Line_Ordered_Quantity] END
FROM [CWC_DW].[Fact].[Sales] (NOLOCK) s
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
	  --WHERE CAST(s.Sales_Line_Created_Date_EST AS DATE) >= '12/1/2020'
  --GROUP BY s.Sales_Line_Product_Key
  ) --SELECT * FROM AUC_Details WHERE Product_Key = 133470
,AUC AS
(
  SELECT
   auc.[Product_Key]
  --,[Net_Units] = ISNULL(SUM([Shipped_Quantity]),0) - ISNULL(SUM([Return_Units]),0)
  --,[Return_Landed_Cost] = SUM([Return_Landed_Cost])
  --,[Shipped_Landed_Cost] = SUM([Shipped_Landed_Cost])
  --,[Landed_Cost] = ISNULL(SUM([Shipped_Landed_Cost]),0) + ISNULL(SUM([Return_Landed_Cost]),0)
  --,[Shipped_Quantity] = SUM([Shipped_Quantity])
  --,[Return_Units] = SUM([Return_Units])
  ,[Average_Unit_Cost] = CASE WHEN (SUM([Shipped_Quantity]) + SUM([Return_Units])) <> 0 THEN (SUM([Shipped_Landed_Cost]) + SUM([Return_Landed_Cost]))/(SUM([Shipped_Quantity]) + SUM([Return_Units])) ELSE NULL END
  FROM AUC_Details auc
  INNER JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON auc.Product_Key = p.Product_Key
  --WHERE Sales_Line_Type = 'Return'
  GROUP BY auc.Product_Key
  )
  --SELECT TOP 1000 * FROM AUC WHERE Average_Unit_Cost < 0 
  --SELECT * FROM AUC WHERE Product_Key = 133470

  UPDATE p
  SET p.[Average_Unit_Cost] = CASE WHEN auc.[Average_Unit_Cost] > 0 THEN auc.[Average_Unit_Cost] ELSE NULL END
  FROM [CWC_DW].[Dimension].[Products] (NOLOCK) p
	  LEFT JOIN auc ON p.Product_Key = auc.Product_Key
  WHERE ISNULL(p.[Average_Unit_Cost],0) <> ISNULL(auc.[Average_Unit_Cost],0);

