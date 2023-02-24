







CREATE VIEW [Power_BI].[v_Selling_Report_Invoices_BACKUP_041822]

AS

SELECT
	 [Invoice Key] = i.Invoice_Key
	,[Sales Key] = i.[Sales_Key]
	,[Product Key] = p.Product_Key
	,[Baked Key] = CASE WHEN is_Baked = 1 THEN 1 ELSE 2 END
	,[Invoice Number] = i.Invoice_Number
	,[Invoice Line Number] = i.Invoice_Line_Number

	,[Sales Order Number] = s.Sales_Order_Number
	,[Sale Line Number] = s.Sales_Line_Number
	,[Sale Date] = CAST(s.Sales_Line_Created_Date_EST AS DATE)
	,[Sale Amount] = s.Sales_Line_Amount
	,[Sale Line Status] = CASE slp.[Sales_Line_Status] WHEN 'Backorder' THEN 'Open' ELSE slp.[Sales_Line_Status] END
	,[Sales Line Type] = slp.Sales_Line_Type
	,[Invoice Delivery Mode] = ip.Invoice_Header_Delivery_Mode
	,[Expedited Shipping] = CASE ip.Expedited_Shipping WHEN 'Not Expedited Shipping' THEN 'Standard Shipping' ELSE ip.Expedited_Shipping END

	,[Invoice Line Date Key] = i.Invoice_Line_Date_Key
	,[Invoice Date] = i.[Invoice_Line_Date]
	
	
	,[Shipped Amount] = CASE WHEN slp.Sales_Line_Type = 'Sale' THEN i.[Invoice_Line_Amount] ELSE NULL END
	,[Shipped Quantity] = CASE WHEN slp.Sales_Line_Type = 'Sale' THEN i.[Invoice_Line_Quantity] ELSE NULL END
	,[Return Invoice Amount] = CASE WHEN slp.Sales_Line_Type = 'Return' THEN i.[Invoice_Line_Amount] ELSE NULL END
	,[Return Invoice Quantity] = CASE WHEN slp.Sales_Line_Type = 'Return' THEN i.[Invoice_Line_Quantity] ELSE NULL END

	,[Return Invoice Missy Quantity] = CASE WHEN slp.Sales_Line_Type = 'Return' AND p.Style_ID = 'M' THEN i.[Invoice_Line_Quantity] ELSE NULL END
	,[Return Invoice Petite Quantity] = CASE WHEN slp.Sales_Line_Type = 'Return' AND p.Style_ID = 'P' THEN i.[Invoice_Line_Quantity] ELSE NULL END
	,[Return Invoice Women Quantity] = CASE WHEN slp.Sales_Line_Type = 'Return' AND p.Style_ID = 'W' THEN i.[Invoice_Line_Quantity] ELSE NULL END

	,[Invoice Discount Amount] = i.Invoice_Line_Discount_Amount
	,i.Invoice_Line_Tax_Amount
	,[Invoice Total Charge Amount] = i.Invoice_Header_Total_Charge_Amount
	,[Invoice Line Charge Amount] = i.Invoice_Line_Charge_Amount
	,[Cost Price] = ISNULL(NULLIF(s.Sales_Line_Cost_Price,0),NULLIF(p.[PO_Weighted_Average_Unit_Cost],0))
	,[Shipped Landed Cost] = ISNULL(NULLIF(s.Sales_Line_Cost_Price,0),NULLIF(p.[PO_Weighted_Average_Unit_Cost],0)) * Invoice_Line_Quantity
	,[Delivery Location Key] = s.Sales_Header_Location_Key
	,[Free Shipping] = ia.Free_Shipping
	,[Backorder Fill] = ia.Backorder_Fill

	,[Sales Invoice Return Reason Group] = CAST((CASE WHEN slp.Sales_Line_Type = 'Return' THEN ISNULL(shp.[Sales_Header_Return_Reason_Group],'{-Not Populated-}') ELSE NULL END) AS VARCHAR(100))
    ,[Sales Invoice Return Reason] = CAST((CASE WHEN slp.Sales_Line_Type = 'Return' THEN ISNULL(shp.[Sales_Header_Return_Reason],'{-Not Populated-}') ELSE NULL END) AS VARCHAR(100))

FROM [CWC_DW].[Fact].[Invoices] (NOLOCK) i
	INNER JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON i.[Invoice_Line_Product_Key] = p.[Product_Key]
	INNER JOIN [CWC_DW].[Dimension].[Invoice_Attributes] (NOLOCK) ia ON i.Invoice_Attribute_Key = ia.Invoice_Attribute_Key
	LEFT JOIN [CWC_DW].[Dimension].[Invoice_Properties] (NOLOCK) ip ON i.Invoice_Property_Key = ip.Invoice_Property_Key
	INNER JOIN [CWC_DW].[Fact].[Sales] (NOLOCK) s ON i.Sales_Key = s.Sales_Key
	INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) d ON d.Calendar_Date = i.[Invoice_Line_Date]
	LEFT JOIN [CWC_DW].[Fact].[Trade_Agreement_Costs] (NOLOCK) tc ON s.Sales_Line_Product_Key = tc.Product_Key AND CAST(s.[Sales_Line_Created_Date] AS DATE) BETWEEN tc.[Start_Date] AND tc.[End_Date]
	LEFT JOIN [CWC_DW].[Dimension].[Sales_Line_Properties] (NOLOCK) slp ON s.Sales_Line_Property_Key = slp.Sales_Line_Property_Key
	LEFT JOIN [CWC_DW].[Dimension].[Sales_Header_Properties] (NOLOCK) shp ON s.Sales_Header_Property_Key = shp.Sales_Header_Property_Key
WHERE 
	    --i.[Invoice_Line_Quantity] > 0 --DISABLED 02/22/22 for to add Returns for Invoice Shipping report
	--AND i.[Invoice_Line_Date] >= '12/01/2020'
	--AND Calendar_Date >= '8/15/2020'
	      p.[Item_ID] NOT IN ('CreditOnly')
	AND (Fiscal_Year BETWEEN DATEPART(YEAR,CAST(GETDATE() AS DATE))-1 AND DATEPART(YEAR,CAST(GETDATE() AS DATE)))

--	  (
--		     (DATEPART(YEAR,CAST(GETDATE() AS DATE)) <> 2022 AND (Fiscal_Year BETWEEN DATEPART(YEAR,CAST(GETDATE() AS DATE))-1 AND DATEPART(YEAR,CAST(GETDATE() AS DATE)))) --Current and Previous Year
--		  OR (DATEPART(YEAR,CAST(GETDATE() AS DATE)) = 2022 AND (Fiscal_Year BETWEEN DATEPART(YEAR,CAST(GETDATE() AS DATE))-3 AND DATEPART(YEAR,CAST(GETDATE() AS DATE)) AND Fiscal_Year <> 2020)) -- Current. Previous and 2019 just for FY 2022
--	  )
--AND slp.Sales_Line_Type = 'Return'
;

