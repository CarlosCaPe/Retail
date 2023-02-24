

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Analytics].[v_Fact_Inventory_Snapshots]

AS

WITH Units AS
(
SELECT 
[Date_Key]
,[Product_Key] = Sales_Line_Product_Key
,[Ordered Units] = SUM(s.Sales_Line_Ordered_Sales_Quantity)
,[Order Unique] = COUNT(DISTINCT Sales_Order_Number)
FROM [CWC_DW].[Fact].[Sales] (NOLOCK) s
LEFT JOIN [CWC_DW].[Dimension].[Sales_Line_Properties] slp ON slp.Sales_Line_Property_Key = s.Sales_Line_Property_Key
INNER JOIN CWC_DW.Dimension.Dates (NOLOCK) d ON CAST(s.Sales_Header_Created_Date AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' AS DATE) = d.Calendar_Date
	--LEFT JOIN Sales_Baked_Free_Shipping sb ON s.Sales_Key = sb.Sales_Key
	--LEFT JOIN BO_Orders boo ON s.Sales_Key = boo.Sales_Key
	--LEFT JOIN Backorders b ON s.Sales_Key = b.Sales_Key AND CAST(s.Sales_Line_Created_Date_EST AS DATE) = b.Snapshot_Date
WHERE CAST(s.Sales_Header_Created_Date AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' AS DATE) >= '1/1/2019' 
AND slp.Sales_Line_Type = 'Sale' AND s.Sales_Line_Ordered_Sales_Quantity > 0 AND s.Sales_Line_Product_Key IS NOT NULL
GROUP BY [Date_Key],Sales_Line_Product_Key
)
SELECT --[Snapshot Date Key] = [Snapshot_Date_Key]
	   --[Inventory Date] = CASE WHEN is_Current_Inventory_Date = 0 THEN  CAST(FORMAT(d.Calendar_Date, 'd','us') AS VARCHAR(20)) ELSE 'Current Inventory Date' END
	   [Inventory Snapshot Date] = d.Calendar_Date
	  ,[Product Key] = p.Product_Key
	  --,[Inventory Date Index] = DENSE_RANK()OVER(ORDER BY d.Calendar_Date DESC)
      --,[Product Key] = i.[Product_Key]
	  
      --,[Inventory_Warehouse_Key] = CAST(i.[Inventory_Warehouse_Key] AS SMALLINT)
	  ,[Inventory Warehouse] = CASE iw.Inventory_Warehouse WHEN 'Distribution Center' THEN 'GEODIS' ELSE iw.Inventory_Warehouse END
	  --,[Inventory Warehouse ID] = iw.Inventory_Warehouse_ID
	  --,[Warehouse Status] = CASE WHEN ISNULL(iw.is_Active,1) = 1 THEN 'Active' ELSE 'Inactive' END
	  --,iw.Inventory_Warehouse_ID
      ,[On Hand Quantity (Available)] =   SUM(CAST(ISNULL([Available_On_Hand_Quantity],0) AS INT))
										+ SUM(CAST(ISNULL(Returns_On_Hand_Quantity,0) AS INT))
										+ SUM(CAST(ISNULL(Warehouse_Damage_On_Hand_Quantity,0) AS INT))
										+ SUM(CAST(ISNULL(Temporary_On_Hand_Quantity,0) AS INT))
										+ SUM(CAST(ISNULL(Blocking_On_Hand_Quantity,0) AS INT))
										+ SUM(CAST(ISNULL(Damaged_But_Available_On_Hand_Quantity,0) AS INT))
										+ SUM(CAST(ISNULL(General_Quarantine_On_Hand_Quantity,0) AS INT))
      --,[Reserved On Hand Quantity (Available)] = SUM(CAST([Available_Reserved_On_Hand_Quantity] AS INT))
      ,[Available On Hand Quantity (Available)] = SUM(CAST([Available_Available_On_Hand_Quantity] AS INT))
	  ,[Ordered Units] = SUM(u.[Ordered Units])
	  --,[Inventory Availble On Hand Cost] = SUM(p.PO_Weighted_Average_Unit_Cost * [Available_Available_On_Hand_Quantity])
	  --,[Inventory On Hand Cost] = SUM(p.PO_Weighted_Average_Unit_Cost * [Available_On_Hand_Quantity])
   --   ,[Ordered Quantiity (Available)] = [Available_Ordered_Quantiity]
      --,[Reserved Ordered Quantity (Available)] = SUM(CAST([Available_Reserved_Ordered_Quantity] AS INT))
      --,[Available Ordered Quantity (Available)] = SUM(CAST([Available_Available_Ordered_Quantity] AS INT))
   --   ,[On Order Quantity (Available)] = [Available_On_Order_Quantity]
   --   ,[Total Available Quantity (Available)] = [Available_Total_Available_Quantity]
   --   ,[Average Cost (Available)] = [Available_Average_Cost]
   --   ,[On Hand Quantity (Returns)] = [Returns_On_Hand_Quantity]
   --   ,[Reserved On Hand Quantity (Returns)] = [Returns_Reserved_On_Hand_Quantity]
   --   ,[Available On Hand Quantity (Returns)] = [Returns_Available_On_Hand_Quantity]
   --   ,[Ordered Quantiity (Returns)] = [Returns_Ordered_Quantiity]
   --   ,[Reserved Ordered Quantity (Returns)] = [Returns_Reserved_Ordered_Quantity]
   --   ,[Available Ordered Quantity (Returns)] = [Returns_Available_Ordered_Quantity]
   --   ,[On Order Quantity (Returns)] = [Returns_On_Order_Quantity]
   --   ,[Total Available Quantity (Returns)] = [Returns_Total_Available_Quantity]
   --   ,[Average Cost (Returns)] = [Returns_Average_Cost]
   --   ,[On Hand Quantity (Damaged)] = [Damaged_On_Hand_Quantity]
   --   ,[Reserved On Hand Quantity (Damaged)] = [Damaged_Reserved_On_Hand_Quantity]
   --   ,[Available On Hand Quantity (Damaged)] = [Damaged_Available_On_Hand_Quantity]
   --   ,[Ordered Quantiity (Damaged)] = [Damaged_Ordered_Quantiity]
   --   ,[Reserved Ordered Quantity (Damaged)] = [Damaged_Reserved_Ordered_Quantity]
   --   ,[Available Ordered Quantity (Damaged)] = [Damaged_Available_Ordered_Quantity]
   --   ,[On Order Quantity (Damaged)] = [Damaged_On_Order_Quantity]
   --   ,[Total Available Quantity (Damaged)] = [Damaged_Total_Available_Quantity]
   --   ,[Average Cost (Damaged)] = [Damaged_Average_Cost]
   --   ,[On Hand Quantity (Damaged But Available)] = [Damaged_But_Available_On_Hand_Quantity]
   --   ,[Reserved On Hand Quantity (Damaged But Available)] = [Damaged_But_Available_Reserved_On_Hand_Quantity]
   --   ,[Available On Hand Quantity (Damaged But Available)] = [Damaged_But_Available_Available_On_Hand_Quantity]
   --   ,[Ordered Quantiity (Damaged But Available)] = [Damaged_But_Available_Ordered_Quantiity]
   --   ,[Reserved Ordered Quantity (Damaged But Available)] = [Damaged_But_Available_Reserved_Ordered_Quantity]
   --   ,[Available Ordered Quantity (Damaged But Available)] = [Damaged_But_Available_Available_Ordered_Quantity]
   --   ,[On Order Quantity (Damaged But Available)] = [Damaged_But_Available_On_Order_Quantity]
   --   ,[Total Available Quantity (Damaged But Available)] = [Damaged_But_Available_Total_Available_Quantity]
   --   ,[Average Cost (Damaged But Available)] = [Damaged_But_Available_Average_Cost]
   --   ,[On Hand Quantity (Receipt Hold)] = [Receipt_Hold_On_Hand_Quantity]
   --   ,[Reserved On Hand Quantity (Receipt Hold)] = [Receipt_Hold_Reserved_On_Hand_Quantity]
   --   ,[Available On Hand Quantity (Receipt Hold)] = [Receipt_Hold_Available_On_Hand_Quantity]
   --   ,[Ordered Quantity (Receipt Hold)] = [Receipt_Hold_Ordered_Quantiity] --<=Typo
   --   ,[Reserved Ordered Quantity (Receipt Hold)] = [Receipt_Hold_Reserved_Ordered_Quantity]
   --   ,[Available Ordered_Quantity (Receipt Hold)] = [Receipt_Hold_Available_Ordered_Quantity]
   --   ,[On Order Quantity (Receipt Hold)] = [Receipt_Hold_On_Order_Quantity]
   --   ,[Total Available Quantity (Receipt Hold)] = [Receipt_Hold_Total_Available_Quantity]
   --   ,[Average Cost (Receipt Hold)] = [Receipt_Hold_Average_Cost]
   --   --,[Temporary_On_Hand_Quantity]
   --   --,[Temporary_Reserved_On_Hand_Quantity]
   --   --,[Temporary_Available_On_Hand_Quantity]
   --   --,[Temporary_Ordered_Quantiity]
   --   --,[Temporary_Reserved_Ordered_Quantity]
   --   --,[Temporary_Available_Ordered_Quantity]
   --   --,[Temporary_On_Order_Quantity]
   --   --,[Temporary_Total_Available_Quantity]
   --   --,[Temporary_Average_Cost]
   --   ,[On Hand Quantity (Warehouse Damage)] = [Warehouse_Damage_On_Hand_Quantity]
   --   ,[Reserved On Hand Quantity (Warehouse Damage)] = [Warehouse_Damage_Reserved_On_Hand_Quantity]
   --   ,[Available On Hand Quantity (Warehouse Damage)] = [Warehouse_Damage_Available_On_Hand_Quantity]
   --   ,[Ordered Quantiity (Warehouse Damage)] = [Warehouse_Damage_Ordered_Quantiity]
   --   ,[Reserved Ordered Quantity (Warehouse Damage)] = [Warehouse_Damage_Reserved_Ordered_Quantity]
   --   ,[Available Ordered Quantity (Warehouse Damage)] = [Warehouse_Damage_Available_Ordered_Quantity]
   --   ,[On Order Quantity (Warehouse Damage)] = [Warehouse_Damage_On_Order_Quantity]
   --   ,[Total Available Quantity (Warehouse Damage)] = [Warehouse_Damage_Total_Available_Quantity]
   --   ,[Average Cost (Warehouse Damage)] = [Warehouse_Damage_Average_Cost]
   --   --,[Blocking_On_Hand_Quantity]
   --   --,[Blocking_Reserved_On_Hand_Quantity]
   --   --,[Blocking_Available_On_Hand_Quantity]
   --   --,[Blocking_Ordered_Quantiity]
   --   --,[Blocking_Reserved_Ordered_Quantity]
   --   --,[Blocking_Available_Ordered_Quantity]
   --   --,[Blocking_On_Order_Quantity]
   --   --,[Blocking_Total_Available_Quantity]
   --   --,[Blocking_Average_Cost]
   --   --,[General_Quarantine_On_Hand_Quantity]
   --   --,[General_Quarantine_Reserved_On_Hand_Quantity]
   --   --,[General_Quarantine_Available_On_Hand_Quantity]
   --   --,[General_Quarantine_Ordered_Quantiity]
   --   --,[General_Quarantine_Reserved_Ordered_Quantity]
   --   --,[General_Quarantine_Available_Ordered_Quantity]
   --   --,[General_Quarantine_On_Order_Quantity]
   --   --,[General_Quarantine_Total_Available_Quantity]
   --   --,[General_Quarantine_Average_Cost]
   --   --,[is_Removed_From_Source]
   --   --,[is_Excluded]
   --   --,[ETL_Created_Date]
   --   --,[ETL_Modified_Date]
   --   --,[ETL_Modified_Count]
	  --,[Extended Cost On Hand] = [Extended_Cost_On_Hand]
	  --,[Extended Cost On Order] = [Extended_Cost_On_Order]
	  --,[On Hand Quantity (Available)] = [Available_On_Hand_Quantity]
	  ----,[WMS On Hand Quantity (Available)] = CAST([Available_WMS_On_Hand_Quantity] AS INT)
	  ----,[WMS Diff ABS] = CAST(ABS(ISNULL([Available_On_Hand_Quantity],0) - ISNULL([Available_WMS_On_Hand_Quantity],0)) AS INT)
	  ----,[WMS AVG] = (ISNULL([Available_On_Hand_Quantity],0) + ISNULL([Available_WMS_On_Hand_Quantity],0))/2
	  --,[WMS On Hand Quantity (Returns)] = [Returns_WMS_On_Hand_Quantity]
	  --,[Damaged WMS On Hand Quantity] = [Damaged_WMS_On_Hand_Quantity]
	  --,[Damaged But Available WMS On Hand Quantity] = [Damaged_But_Available_WMS_On_Hand_Quantity]
	  --,[Receipt Hold Available WMS On Hand Quantity] = [Receipt_Hold_Available_WMS_On_Hand_Quantity]
	  --,[Temporary WMS On Hand Quantity] = [Temporary_WMS_On_Hand_Quantity]
	  --,[Warehouse Damage WMS On Hand Quantity] = [Warehouse_Damage_WMS_On_Hand_Quantity]
	  --,[Blocking WMS On Hand Quantity] = [Blocking_WMS_On_Hand_Quantity]
	  --,[General Quarantine WMS On Hand Quantity] = [General_Quarantine_WMS_On_Hand_Quantity]

	  --,[On Hand Quantity (Available)] = [Available_On_Hand_Quantity]
	 
	  --,[WMS Var] = ISNULL([Available_On_Hand_Quantity],0) - ISNULL([Available_WMS_On_Hand_Quantity],0)
	  --,[WMS Var Rate] = CASE WHEN ([Available_On_Hand_Quantity] + [Available_WMS_On_Hand_Quantity]) <> 0 THEN (ABS([Available_On_Hand_Quantity] - [Available_WMS_On_Hand_Quantity])/(([Available_On_Hand_Quantity] + [Available_WMS_On_Hand_Quantity])/2)) ELSE NULL END
	  --,[WMS Var Rate] = CASE WHEN (ISNULL([Available_On_Hand_Quantity],0) + ISNULL([Available_WMS_On_Hand_Quantity],0)) <> 0 THEN ((ISNULL([Available_On_Hand_Quantity],0) - ISNULL([Available_WMS_On_Hand_Quantity],0))/((ISNULL([Available_On_Hand_Quantity],0) + ISNULL([Available_WMS_On_Hand_Quantity],0))/2)) ELSE NULL END
  FROM [CWC_DW].[Fact].[Inventory] (NOLOCK) i
  LEFT JOIN [CWC_DW].[Dimension].[Inventory_Warehouses] (NOLOCK) iw ON i.Inventory_Warehouse_Key = iw.Inventory_Warehouse_Key
  INNER JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON i.Product_Key = p.Product_Key
  INNER JOIN [CWC_DW].[Dimension].[Dates] (NOLOCK) d ON d.Date_Key = i.Snapshot_Date_Key
  LEFT JOIN Units u ON i.Snapshot_Date_Key = u.Date_Key AND u.Product_Key = i.Product_Key
  WHERE 
  --i.Snapshot_Date_Key = (SELECT MAX(Snapshot_Date_Key) FROM [CWC_DW].[Fact].[Inventory] (NOLOCK))
  /*AND*/ i.[is_Excluded] = 0 AND i.is_Removed_From_Source = 0 AND iw.is_Active = 1 
  AND ((iw.Inventory_Warehouse IN ('Distribution Center') AND Calendar_Date <= '2022-08-27')
  OR (iw.Inventory_Warehouse = 'XB' AND Calendar_Date > '2022-08-27'))
  AND Available_On_Hand_Quantity > 0
  --AND d.Calendar_Date >= DATEADD(DAY,-30,CAST(GETDATE() AS DATE))
--  AND (d.Calendar_Date IN (SELECT TOP 20 DATEADD(DAY,1,First_Date_of_Week) FROM [CWC_DW].[Dimension].[Dates] WHERE Calendar_Date <= CAST(GETDATE() AS DATE) AND DATEADD(DAY,1,First_Date_of_Week) < CAST(GETDATE() AS DATE) GROUP BY  DATEADD(DAY,1,First_Date_of_Week) ORDER BY DATEADD(DAY,1,First_Date_of_Week) DESC)
--OR is_Current_Inventory_Date = 1 
--OR d.Calendar_Date = '03/01/2021'
--)
GROUP BY
	d.Calendar_Date,p.Product_Key,CASE iw.Inventory_Warehouse WHEN 'Distribution Center' THEN 'GEODIS' ELSE iw.Inventory_Warehouse END
/*HAVING SUM(CAST(ISNULL([Available_On_Hand_Quantity],0) AS INT))
										+ SUM(CAST(ISNULL(Returns_On_Hand_Quantity,0) AS INT))
										+ SUM(CAST(ISNULL(Warehouse_Damage_On_Hand_Quantity,0) AS INT))
										+ SUM(CAST(ISNULL(Temporary_On_Hand_Quantity,0) AS INT))
										+ SUM(CAST(ISNULL(Blocking_On_Hand_Quantity,0) AS INT))
										+ SUM(CAST(ISNULL(Damaged_But_Available_On_Hand_Quantity,0) AS INT))
										+ SUM(CAST(ISNULL(General_Quarantine_On_Hand_Quantity,0) AS INT)) > 0*/
;