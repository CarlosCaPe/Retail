











CREATE VIEW [Power_BI].[v_Dim_Products_Backordered] AS

WITH Backorder_Products AS
	(
		SELECT
			 [Backorder_Product_Key] = b.Sales_Line_Product_Key
		FROM [CWC_DW].[Fact].[Backorders] (NOLOCK) b
			INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) sd ON b.[Snapshot_Date_Key] = sd.[Date_Key]
			INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) bd ON CAST(b.[Sales_Line_Created_Date] AS DATE) = bd.[Calendar_Date]
			INNER JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON b.Sales_Line_Product_Key = p.Product_Key
			LEFT JOIN [CWC_DW].[Fact].[Purchase_Orders] (NOLOCK) po ON p.Earliest_Open_Purchase_Order_Key = po.Purchase_Order_Key
		WHERE sd.Current_Backorder_Date = 'Current Backorder Date'
		--AND Item_ID = '11729'
		AND b.is_Removed_From_Source = 0
		GROUP BY b.Sales_Line_Product_Key
	)
SELECT --TOP 1200
	   [Product Key] = p.[Product_Key]
      ,[Product Varient Number] = [Product_Varient_Number]
      ,[Department] = [Department_Name]
      ,[Class] = [Class_Name]
      ,[Product_Search_Name]
	  ,[Item Number] = p.Item_ID
      ,[Item] = p.Item_Name_Standard
	  ,[Item Number - Name] = p.[Item_ID] + ' - ' + ISNULL(p.Item_Name_Standard,[Item_Name])
      ,[Color] = [Color_Name]
      ,[Size] = [Size_Name]
      ,[Style] = [Style_Name]
      --,[Sales_Price]
      --,[Sales_Price_Date]
      --,[Purchase_Price]
      --,[Purchase_Price_Date]
      ,[Vendor] = [Vendor_Name]
      --,[Department_ID]
      --,[Class_ID]
      
      ,[Color ID] = [Color_ID]
      ,[Size ID] = [Size_ID]
      ,[Style ID] = [Style_ID]
	  ,[SKU] = CONCAT(p.[Item_ID],[Color_ID],[Size_ID])
      ,[Vendor Account Number] = p.[Vendor_Account_Number]
	  ,[Active Product] = CASE is_Active_Product WHEN 1 THEN 'Active Product' ELSE 'Not Active Product' END
	  ,[Earliest Open Sales Order Number] = s.Sales_Order_Number
	  ,[Sales Line Number] = s.Sales_Line_Number
	  ,[Sales Line Ordered Quantity] = s.Sales_Line_Ordered_Quantity
	  ,[Sales Line Amount] = s.Sales_Line_Amount
	  ,[Sales Line Discount Amount] = s.Sales_Line_Discount_Amount
	  ,[Sales Line Created Date] = CAST([Sales_Line_Created_Date_EST] AS DATE)
	  ,[Sales Line Created Fiscal Month] = REPLACE(sod.Fiscal_Month_Year,'-',' ')
	  ,[Sales Line Fiscal Week of Year Name] = sod.[Fiscal_Week_of_Year_Name]
	  ,[Earliest Open Purchase Order Number] = po.Purchase_Order_Number
	  ,[Purchase Order Line Number] = po.Purchase_Order_Line_Number
	  ,[Purchase Order Name] = po.Purchase_Order_Name
	  ,[Purchase Line Description] = po.Purchase_Line_Description
	  ,[Purchase Line Amount] = po.Purchase_Line_Amount
	  ,[Purchase Line Ordered Quantity] = po.Purchase_Line_Ordered_Quantity
	  ,[Purchase Order Header Accounting Date] = po.Purchase_Order_Header_Accounting_Date
	  ,[Purchase Line Confirmed Delivery Date] = po.Purchase_Line_Confirmed_Delivery_Date
	  ,[Purchase Line Fiscal Month Year Index] = CAST(CAST(pod.[Fiscal_Year] AS VARCHAR(4)) +  CAST((pod.[Fiscal_Month] + 10) AS VARCHAR(2)) AS INT)
	  ,[Purchase Line Fiscal Month Year] = LEFT(pod.[Fiscal_Month_Name],3) + ' ' + CAST(pod.Fiscal_Year AS VARCHAR(4))
	  ,[Purchase Line Confirmed Fiscal Week] = pod.Fiscal_Week_of_Year_Name
	  ,[Purchase Line Confirmed Fiscal Week Index] = CAST(CAST(pod.Fiscal_Year AS VARCHAR(4)) + CAST((pod.Fiscal_Week_of_Year + 100) AS VARCHAR(3)) AS INT)
	  ,[Trade Agreement Cost] = Trade_Agreement_Cost
	  ,[Trade Agreement Price] = Trade_Agreement_Price
      ,[First Catalog Number] = fc.Catalog_Number
	  ,[First Catalog Name] = fc.Catalog_Name
	  ,[First Catalog Drop Date] = fc.Catalog_Drop_Date
	  ,[Current Catalog Number] = cc.Catalog_Number
	  ,[Current Catalog Name] = cc.Catalog_Name
	  ,[Current Catalog Drop Date] = cc.Catalog_Drop_Date
	  ,[Next Catalog Number] = nc.Catalog_Number
	  ,[Next Catalog Name] = nc.Catalog_Name
	  ,[Next Catalog Drop Date] = nc.Catalog_Drop_Date	
	  ,[First Receipt Date] = vps.Vendor_Packing_Accounting_Date
	  ,[Average Unit Retail] = p.Average_Unit_Retail
	  ,Risk = p.Risk
	  --,Available_Available_On_Hand_Quantity = ISNULL(i.Available_Available_On_Hand_Quantity,0)
	  --,Available_Available_Ordered_Quantity = ISNULL(i.Available_Available_Ordered_Quantity,0)
	  --,i.
      --,[is_Removed_From_Source]
      --,[is_Excluded]
      --,[ETL_Created_Date]
      --,[ETL_Modified_Date]
      --,[ETL_Modified_Count]
  FROM [CWC_DW].[Dimension].[Products] (NOLOCK) p
  INNER JOIN Backorder_Products bp ON p.Product_Key = bp.Backorder_Product_Key
	  LEFT JOIN [CWC_DW].[Fact].[Sales] (NOLOCK) s ON p.Earliest_Open_Sales_Key = s.Sales_Key
	  LEFT JOIN [CWC_DW].[Fact].[Purchase_Orders] (NOLOCK) po ON p.Earliest_Open_Purchase_Order_Key = po.Purchase_Order_Key
	  --LEFT JOIN [CWC_DW].[Fact].[Inventory] (NOLOCK) i ON i.Product_Key = p.Product_Key 
			--										  AND i.Snapshot_Date_Key = (SELECT MAX(Snapshot_Date_Key) FROM [CWC_DW].[Fact].[Inventory] (NOLOCK))
			--										  AND i.Inventory_Warehouse_Key = (SELECT Inventory_Warehouse_Key FROM [CWC_DW].[Dimension].[Inventory_Warehouses] WHERE Inventory_Warehouse = 'Distribution Center')
	  LEFT JOIN [CWC_DW].[Dimension].[Dates] (NOLOCK) pod ON po.Purchase_Line_Confirmed_Delivery_Date = pod.Calendar_Date
	  LEFT JOIN [CWC_DW].[Dimension].[Dates] (NOLOCK) sod ON CAST([Sales_Line_Created_Date_EST] AS DATE) = sod.Calendar_Date
	  LEFT JOIN [CWC_DW].[Dimension].[Catalogs] (NOLOCK) fc ON p.First_Catalog_Key = fc.Catalog_Key
	  LEFT JOIN [CWC_DW].[Dimension].[Catalogs] (NOLOCK) cc ON p.Current_Catalog_Key = cc.Catalog_Key
	  LEFT JOIN [CWC_DW].[Dimension].[Catalogs] (NOLOCK) nc ON p.Next_Catalog_Key = nc.Catalog_Key
	  LEFT JOIN [CWC_DW].[Fact].[Vendor_Packing_Slips] (NOLOCK) vps ON vps.Vendor_Packing_Slip_Key = p.[First_Vendor_Packing_Slip_Key]
	  --LEFT JOIN Item_Name_Standard ins ON p.Item_ID = ins.Item_ID
	  --INNER JOIN [CWC_DW].[Dimension].[Inventory_Warehouses] (NOLOCK) iw ON iw.[Inventory_Warehouse_Key] = i.[Inventory_Warehouse_Key]
  --WHERE p.[Product_Key] = '190727'
  --AND p.Item_ID = '18623'
 /*WHERE is_Active_Product = 1 AND i.Available_Available_On_Hand_Quantity IS NULL
  AND Item_ID = '67002'*/
  ;

