﻿


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [ADHOC].[v_Inventory_Current]

AS

SELECT --[Snapshot_Date_Key]
       --[Product_Key]
      --,[Inventory_Warehouse_Key] = CAST(i.[Inventory_Warehouse_Key] AS SMALLINT)
	   [Inventory_Warehouse] = iw.Inventory_Warehouse
	  --,iw.Inventory_Warehouse_ID
	  ,p.Item_ID
	  ,Color_ID
	  ,Size_ID
	  ,Item_Name
	  ,Color_Name
	  ,Size_Name
      ,[Available_On_Hand_Quantity]
      ,[Available_Reserved_On_Hand_Quantity]
      ,[Available_Available_On_Hand_Quantity]
      ,[Available_Ordered_Quantiity]
      ,[Available_Reserved_Ordered_Quantity]
      ,[Available_Available_Ordered_Quantity]
      ,[Available_On_Order_Quantity]
      ,[Available_Total_Available_Quantity]
      --,[Available_Average_Cost]
      --,[Returns_On_Hand_Quantity]
      --,[Returns_Reserved_On_Hand_Quantity]
      --,[Returns_Available_On_Hand_Quantity]
      --,[Returns_Ordered_Quantiity]
      --,[Returns_Reserved_Ordered_Quantity]
      --,[Returns_Available_Ordered_Quantity]
      --,[Returns_On_Order_Quantity]
      --,[Returns_Total_Available_Quantity]
      --,[Returns_Average_Cost]
      --,[Damaged_On_Hand_Quantity]
      --,[Damaged_Reserved_On_Hand_Quantity]
      --,[Damaged_Available_On_Hand_Quantity]
      --,[Damaged_Ordered_Quantiity]
      --,[Damaged_Reserved_Ordered_Quantity]
      --,[Damaged_Available_Ordered_Quantity]
      --,[Damaged_On_Order_Quantity]
      --,[Damaged_Total_Available_Quantity]
      --,[Damaged_Average_Cost]
      --,[Damaged_But_Available_On_Hand_Quantity]
      --,[Damaged_But_Available_Reserved_On_Hand_Quantity]
      --,[Damaged_But_Available_Available_On_Hand_Quantity]
      --,[Damaged_But_Available_Ordered_Quantiity]
      --,[Damaged_But_Available_Reserved_Ordered_Quantity]
      --,[Damaged_But_Available_Available_Ordered_Quantity]
      --,[Damaged_But_Available_On_Order_Quantity]
      --,[Damaged_But_Available_Total_Available_Quantity]
      --,[Damaged_But_Available_Average_Cost]
      --,[Receipt_Hold_On_Hand_Quantity]
      --,[Receipt_Hold_Reserved_On_Hand_Quantity]
      --,[Receipt_Hold_Available_On_Hand_Quantity]
      --,[Receipt_Hold_Ordered_Quantiity]
      --,[Receipt_Hold_Reserved_Ordered_Quantity]
      --,[Receipt_Hold_Available_Ordered_Quantity]
      --,[Receipt_Hold_On_Order_Quantity]
      --,[Receipt_Hold_Total_Available_Quantity]
      --,[Receipt_Hold_Average_Cost]
      --,[Temporary_On_Hand_Quantity]
      --,[Temporary_Reserved_On_Hand_Quantity]
      --,[Temporary_Available_On_Hand_Quantity]
      --,[Temporary_Ordered_Quantiity]
      --,[Temporary_Reserved_Ordered_Quantity]
      --,[Temporary_Available_Ordered_Quantity]
      --,[Temporary_On_Order_Quantity]
      --,[Temporary_Total_Available_Quantity]
      --,[Temporary_Average_Cost]
      --,[Warehouse_Damage_On_Hand_Quantity]
      --,[Warehouse_Damage_Reserved_On_Hand_Quantity]
      --,[Warehouse_Damage_Available_On_Hand_Quantity]
      --,[Warehouse_Damage_Ordered_Quantiity]
      --,[Warehouse_Damage_Reserved_Ordered_Quantity]
      --,[Warehouse_Damage_Available_Ordered_Quantity]
      --,[Warehouse_Damage_On_Order_Quantity]
      --,[Warehouse_Damage_Total_Available_Quantity]
      --,[Warehouse_Damage_Average_Cost]
      ----,[Blocking_On_Hand_Quantity]
      --,[Blocking_Reserved_On_Hand_Quantity]
      --,[Blocking_Available_On_Hand_Quantity]
      --,[Blocking_Ordered_Quantiity]
      --,[Blocking_Reserved_Ordered_Quantity]
      --,[Blocking_Available_Ordered_Quantity]
      --,[Blocking_On_Order_Quantity]
      --,[Blocking_Total_Available_Quantity]
      --,[Blocking_Average_Cost]
      --,[General_Quarantine_On_Hand_Quantity]
      --,[General_Quarantine_Reserved_On_Hand_Quantity]
      --,[General_Quarantine_Available_On_Hand_Quantity]
      --,[General_Quarantine_Ordered_Quantiity]
      --,[General_Quarantine_Reserved_Ordered_Quantity]
      --,[General_Quarantine_Available_Ordered_Quantity]
      --,[General_Quarantine_On_Order_Quantity]
      --,[General_Quarantine_Total_Available_Quantity]
      --,[General_Quarantine_Average_Cost]
      --,[is_Removed_From_Source]
      --,[is_Excluded]
      --,[ETL_Created_Date]
      --,[ETL_Modified_Date]
      --,[ETL_Modified_Count]
	  ,[Extended_Cost_On_Hand]
	  ,[Extended_Cost_On_Order]
  FROM [CWC_DW].[Fact].[Inventory] (NOLOCK) i
  LEFT JOIN [CWC_DW].[Dimension].[Inventory_Warehouses] (NOLOCK) iw ON i.Inventory_Warehouse_Key = iw.Inventory_Warehouse_Key
  INNER JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON i.Product_Key = p.Product_Key
  WHERE i.Snapshot_Date_Key = (SELECT MAX(Snapshot_Date_Key) FROM [CWC_DW].[Fact].[Inventory] (NOLOCK))
  AND i.[is_Excluded] = 0 AND i.is_Removed_From_Source = 0;