


CREATE VIEW [Analytics].[v_Dim_Products] AS

--WITH Item_Name_Standard AS
--	(
--		SELECT Item_ID,Item_Name_Standard = MAX(Item_Name)
--		FROM [CWC_DW].[Dimension].[Products] (NOLOCK) p
--		--WHERE Item_ID = '18623'
--		GROUP BY Item_ID
--	)
SELECT --TOP 1200
	   [Product Key] = p.[Product_Key]
      --,[Product Varient Number] = [Product_Varient_Number]
      ,[Department] = ISNULL([Department_Name],'{-No Department-}')
      ,[Class] = ISNULL([Class_Name],'{-No Class-}')
      --,[Product Search Name] = [Product_Search_Name]
	  ,[Item Number] = p.[Item_ID]
      ,[Item] = ISNULL(p.Item_Name_Standard,'{-No Item-}') -- Create Item Standard field sp updated
	  ,[Item Number Name] = ISNULL(p.Item_Number_Name,'{-No Item-}') --p.[Item_ID] + ' - ' + ISNULL(Item_Name_Standard,[Item_Name]) --Create Item Numer name calcu;lated field
      ,[Color] = ISNULL([Color_Name],'{-No Color-}')
      ,[Size] = ISNULL([Size_Name],'{-No Size-}')
      ,[Style] = ISNULL([Style_Name],'{-No Style-}')
	  ,[Item Color ID] = CONCAT(Item_ID,Color_ID)
      --,[Sales_Price]
      --,[Sales_Price_Date]
      --,[Purchase_Price]
      --,[Purchase_Price_Date]
      --,[Vendor] = ISNULL([Vendor_Name],'{-No Vendor-}')
      --,[Department_ID]
      --,[Class_ID]
	  --,[Sale Price] = p.Sales_Price
      --,[Price Status] = CASE
						--	WHEN ISNULL(Style_ID,'') IN ('M','P','T','') AND ISNULL(p.Trade_Agreement_Price,0) <= 30 AND ISNULL(p.Trade_Agreement_Price,0) - ISNULL(p.Sales_Price,0) <= 5 THEN 'Full Price'
						--	WHEN ISNULL(Style_ID,'') IN ('M','P','T','') AND ISNULL(p.Trade_Agreement_Price,0) > 30 AND ISNULL(p.Trade_Agreement_Price,0) - ISNULL(p.Sales_Price,0) <= 10 THEN 'Full Price'
						--	WHEN ISNULL(Style_ID,'') IN ('W','') AND ISNULL(p.Trade_Agreement_Price,0) > 79.95 AND ISNULL(p.Trade_Agreement_Price,0) - ISNULL(p.Sales_Price,0) <= 20 THEN 'Full Price'
						--	WHEN ISNULL(Style_ID,'') IN ('W','') AND ISNULL(p.Trade_Agreement_Price,0) <= 79.95 AND ISNULL(p.Trade_Agreement_Price,0) - ISNULL(p.Sales_Price,0) <= 10 THEN 'Full Price'
						--ELSE 'Markdown' END
      ,[Color ID] = [Color_ID]
      ,[Size ID] = [Size_ID]
      ,[Style ID] = [Style_ID]
	  --,[SKU] = p.SKU --CONCAT(p.[Item_ID],[Color_ID],[Size_ID]) --Create calculated field
      --,[Vendor Account] = p.[Vendor_Account_Number]
	  
	  --,[Earliest Open Sales Order Number] = s.Sales_Order_Number --
	  --,[Sales Line Number] = s.Sales_Line_Number
	  --,[Sales Line Ordered Quantity] = s.Sales_Line_Ordered_Quantity
	  --,[Sales Line Amount] = s.Sales_Line_Amount
	  --,[Sales Line Discount Amount] = s.Sales_Line_Discount_Amount
	  --,[Sales Line Created Date] = CAST(s.Sales_Line_Created_Date_EST AS DATE)
	  --,[Sales Line Created Fiscal Month] = REPLACE(sod.Fiscal_Month_Year,'-',' ')
	  --,[Sales Line Fiscal Week of Year Name] = sod.[Fiscal_Week_of_Year_Name]
	  /*
	  ,[Earliest Open Purchase Order Number] = po.Purchase_Order_Number
	  ,[Purchase Order Line Number] = po.Purchase_Order_Line_Number
	  ,[Purchase Order Name] = po.Purchase_Order_Name
	  ,[Purchase Line Description] = po.Purchase_Line_Description
	  ,[Purchase Line Amount] = po.Purchase_Line_Amount
	  ,[Purchase Line Ordered Quantity] = po.Purchase_Line_Ordered_Quantity
	  ,[Purchase Order Header Accounting Date] = po.Purchase_Order_Header_Accounting_Date
	  ,[Purchase Line Confirmed Delivery Date] = po.Purchase_Line_Confirmed_Delivery_Date
	  ,[Purchase Line Fiscal Month Year Index] = pod.[Fiscal_Year] + CAST(pod.[Fiscal_Month] AS VARCHAR(4))
	  ,[Purchase Line Fiscal Month Year] = LEFT(pod.[Fiscal_Month_Name],3) + ' ' + CAST(pod.Fiscal_Year AS VARCHAR(4))
	  ,[Purchase Line Confirmed Fiscal Week] = pod.Fiscal_Week_of_Year_Name
	  ,[Purchase Line Confirmed Fiscal Week Index] = CAST(pod.Fiscal_Year AS INT) + 1000 + CAST(pod.Fiscal_Week_of_Year AS INT)
	  */
	  --,[Trade Agreement Cost] = CASE WHEN p.Trade_Agreement_Cost > 0 THEN p.Trade_Agreement_Cost ELSE NULL END
	  ,[Current MSRP] = CASE WHEN p.Trade_Agreement_Price > 0 THEN p.Trade_Agreement_Price ELSE NULL END
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
	  
	  ,[Risk] = p.Risk
	  --,[Purchase Order Open Quantity] = NULLIF([Purchase_Order_Open_Quantity],0)
	  --,[Sales Order Open Quantity] = NULLIF([Sales_Order_Open_Quantity],0)
	  --,[Average Unit Cost] = p.Average_Unit_Cost 
	  ,[Average Unit Retail] = p.Average_Unit_Retail
	  ,[Weighted Average Unit Cost] = p.[PO_Weighted_Average_Unit_Cost]
	  ,[Active Product] = CASE is_Active_Product WHEN 1 THEN 'Yes' ELSE 'No' END
	  ,[Currently Backordered] = CASE is_Currently_Backordered WHEN 1 THEN 'Yes' ELSE 'No' END
	  ,[Hard Mark] = CASE WHEN is_Hard_Mark = 1 THEN 'Yes' ELSE 'No' END
	  ,[Soft Mark] = CASE WHEN is_Soft_Mark = 1 THEN 'Yes' ELSE 'No' END
	  ,[Timed Event] = CASE WHEN is_Timed_Event = 1 THEN 'Yes' ELSE 'No' END
	  ,[Current Price] = CASE 
							WHEN [Offer_Price_Timed_Event] > 0 THEN [Offer_Price_Timed_Event]
							WHEN [Offer_Price_Soft_Mark] > 0 THEN [Offer_Price_Soft_Mark]
							WHEN [Offer_Price_Hard_Mark] > 0 THEN [Offer_Price_Hard_Mark]
						ELSE [Trade_Agreement_Price] END
	  --,[Weighted Average Cost] = p.PO_Weighted_Average_Unit_Cost
	  --,Available_Available_On_Hand_Quantity = ISNULL(i.Available_Available_On_Hand_Quantity,0)
	  --,Available_Available_Ordered_Quantity = ISNULL(i.Available_Available_Ordered_Quantity,0)
	  --,i.
      --,[is_Removed_From_Source]
      --,[is_Excluded]
      --,[ETL_Created_Date]
      --,[ETL_Modified_Date]
      --,[ETL_Modified_Count]
  FROM [CWC_DW].[Dimension].[Products] (NOLOCK) p
	  LEFT JOIN [CWC_DW].[Fact].[Sales] (NOLOCK) s ON p.Earliest_Open_Sales_Key = s.Sales_Key
	  LEFT JOIN [CWC_DW].[Fact].[Purchase_Orders] (NOLOCK) po ON p.Earliest_Open_Purchase_Order_Key = po.Purchase_Order_Key
	  --LEFT JOIN [CWC_DW].[Fact].[Inventory] (NOLOCK) i ON i.Product_Key = p.Product_Key 
			--										  AND i.Snapshot_Date_Key = (SELECT MAX(Snapshot_Date_Key) FROM [CWC_DW].[Fact].[Inventory] (NOLOCK))
			--										  AND i.Inventory_Warehouse_Key = (SELECT Inventory_Warehouse_Key FROM [CWC_DW].[Dimension].[Inventory_Warehouses] WHERE Inventory_Warehouse = 'Distribution Center')
	  LEFT JOIN [CWC_DW].[Dimension].[Dates] (NOLOCK) pod ON po.Purchase_Line_Confirmed_Delivery_Date = pod.Calendar_Date
	  LEFT JOIN [CWC_DW].[Dimension].[Dates] (NOLOCK) sod ON CAST(DATEADD(hh,-4,[Sales_Line_Created_Date]) AS DATE) = sod.Calendar_Date
	  LEFT JOIN [CWC_DW].[Dimension].[Catalogs] (NOLOCK) fc ON p.First_Catalog_Key = fc.Catalog_Key
	  LEFT JOIN [CWC_DW].[Dimension].[Catalogs] (NOLOCK) cc ON p.Current_Catalog_Key = cc.Catalog_Key
	  LEFT JOIN [CWC_DW].[Dimension].[Catalogs] (NOLOCK) nc ON p.Next_Catalog_Key = nc.Catalog_Key
	  LEFT JOIN [CWC_DW].[Fact].[Vendor_Packing_Slips] (NOLOCK) vps ON vps.Vendor_Packing_Slip_Key = p.[First_Vendor_Packing_Slip_Key]

;

