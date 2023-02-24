
CREATE PROC [Import].[usp_Dimension_Product_Purchase_Orders_Sales_Orders_Quantity_Update]

AS

WITH Purchase_Order_Open AS
	(
		SELECT 
			 [Product_Key] = po.[Product Key]
			,[Purchase_Order_Open_Quantity] = SUM(po.[Purchase Line Open Quantity])
		FROM [CWC_DW].[Power_BI].[v_Fact_Purchase_Orders] (NOLOCK) po --ON vps.Purchase_Order_Key = po.[Purchase Order Key]
		INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) d ON po.[Purchase_Line_Confirmed_Delivery_Date_Key] = d.Date_Key
		WHERE po.[Purchase Order Header Accounting Date] >= '8/15/2020'
		AND po.[Purchase Order Line Status] IN ('Open','Received') AND po.[Purchase Line Open Quantity] > 0
		GROUP BY po.[Product Key]
	)
,Sales_Order_Open AS
	(
	  SELECT [Product_Key] = s.Sales_Line_Product_Key
			,[Sales_Order_Open_Quantity] = SUM(s.Sales_Line_Remain_Sales_Physical)
	  FROM [CWC_DW].[Fact].[Sales] (NOLOCK) s
		  INNER JOIN [CWC_DW].[Dimension].[Dates] (NOLOCK) d ON d.Calendar_Date = CAST(DATEADD(hh,-5,s.[Sales_Line_Created_Date]) AS DATE)
		  INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes] (NOLOCK) soa ON s.[Sales_Order_Attribute_Key] = soa.[Sales_Order_Attribute_Key]
		  --LEFT JOIN [CWC_DW].[Fact].[Invoices] i ON i.Sales_Key = s.Sales_Key --AND i.Seq = 1
		  LEFT JOIN [CWC_DW].[Dimension].[Sales_Line_Properties] (NOLOCK) slp ON s.Sales_Line_Property_Key = slp.Sales_Line_Property_Key
		  LEFT JOIN [CWC_DW].[Dimension].[Sales_Header_Properties] (NOLOCK) shp ON s.Sales_Header_Property_Key = shp.Sales_Header_Property_Key
		  --LEFT JOIN [CWC_DW].[Dimension].[Sales_Order_Fill] (NOLOCK) sof ON s.Sales_Order_Fill_Key = sof.Sales_Order_Fill_Key
		  LEFT JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON s.Sales_Line_Product_Key = p.Product_Key
		  --LEFT JOIN [CWC_DW].[Dimension].[Customers] (NOLOCK) c ON s.[Sales_Header_Customer_Key] = c.Customer_Key
		  --LEFT JOIN [CWC_DW].[Fact].[Sales] (NOLOCK) es ON es.Sales_Key = p.Earliest_Open_Sales_Key
		  --LEFT JOIN [CWC_DW].[Fact].[Credit_Card_Declines] (NOLOCK) ccd ON s.[Sales_Order_Number] = ccd.Sales_Order_Number
		  --LEFT JOIN [CWC_DW].[Dimension].[Credit_Card_Authorizations] (NOLOCK) cca ON ccd.Credit_Card_Authorization_Key = cca.Credit_Card_Authorization_Key
	  WHERE soa.[Order_Classification] = 'Sale'
	 -- AND sof.[Sales_Order_Fill] IN ('Partial Fill','No Fill')
	  AND CAST(s.Sales_Line_Created_Date_EST AS DATE) >= '12/1/2020'
	  AND (shp.Sales_Header_Status NOT IN ('Canceled','Invoced') AND slp.Sales_Line_Status = 'Backorder')
	  AND s.is_Removed_From_Source = 0
	  GROUP BY s.Sales_Line_Product_Key
	)
--SELECT
UPDATE p
SET
	--P.Product_Key,
	 [Purchase_Order_Open_Quantity] = ISNULL(po.[Purchase_Order_Open_Quantity],0)
	,[Sales_Order_Open_Quantity] = ISNULL(so.[Sales_Order_Open_Quantity],0)
FROM [CWC_DW].[Dimension].[Products] (NOLOCK) p
	LEFT JOIN Purchase_Order_Open po ON po.Product_Key = p.Product_Key
	LEFT JOIN Sales_Order_Open so ON so.Product_Key = p.Product_Key
WHERE 
		ISNULL(p.[Purchase_Order_Open_Quantity],0) <> ISNULL(po.[Purchase_Order_Open_Quantity],0)
	OR ISNULL(p.[Sales_Order_Open_Quantity],0) <> ISNULL(so.[Sales_Order_Open_Quantity],0);