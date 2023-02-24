﻿




/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Power_BI].[v_Selling_Report_Inventory_Current]

AS

SELECT --[Snapshot_Date_Key]
       [Product_Key]
      --,[Inventory_Warehouse_Key] = CAST(i.[Inventory_Warehouse_Key] AS SMALLINT)
	  ,[Inventory Warehouse] = iw.Inventory_Warehouse
	  --,iw.Inventory_Warehouse_ID
      ,[On Hand Quantity (Available)] = [Available_On_Hand_Quantity]
      ,[Reserved On Hand Quantity (Available)] = [Available_Reserved_On_Hand_Quantity]
      ,[Available On Hand Quantity (Available)] = [Available_Available_On_Hand_Quantity]
      ,[Ordered Quantiity (Available)] = [Available_Ordered_Quantiity]
      ,[Reserved_Ordered_Quantity (Available)] = [Available_Reserved_Ordered_Quantity]
      ,[Available Ordered Quantity (Available)] = [Available_Available_Ordered_Quantity]
      ,[On Order Quantity (Available)] = [Available_On_Order_Quantity]
      ,[Total Available Quantity (Available)] = [Available_Total_Available_Quantity]
      ,[Average Cost (Available)] = [Available_Average_Cost]
      ,[On Hand Quantity (Returns)] = [Returns_On_Hand_Quantity]
      ,[Reserved On Hand Quantity (Returns)] = [Returns_Reserved_On_Hand_Quantity]
      ,[Available On Hand Quantity (Returns)] = [Returns_Available_On_Hand_Quantity]
      ,[Ordered Quantiity (Returns)] = [Returns_Ordered_Quantiity]
      ,[Reserved Ordered Quantity (Returns)] = [Returns_Reserved_Ordered_Quantity]
      ,[Available Ordered Quantity (Returns)] = [Returns_Available_Ordered_Quantity]
      ,[On Order Quantity (Returns)] = [Returns_On_Order_Quantity]
      ,[Total Available Quantity (Returns)] = [Returns_Total_Available_Quantity]
      ,[Average Cost (Returns)] = [Returns_Average_Cost]
      ,[On Hand Quantity (Damaged)] = [Damaged_On_Hand_Quantity]
      ,[Reserved On Hand Quantity (Damaged)] = [Damaged_Reserved_On_Hand_Quantity]
      ,[Available On Hand Quantity (Damaged)] = [Damaged_Available_On_Hand_Quantity]
      ,[Ordered Quantiity (Damaged)] = [Damaged_Ordered_Quantiity]
      ,[Reserved Ordered Quantity (Damaged)] = [Damaged_Reserved_Ordered_Quantity]
      ,[Available Ordered Quantity (Damaged)] = [Damaged_Available_Ordered_Quantity]
      ,[On Order Quantity (Damaged)] = [Damaged_On_Order_Quantity]
      ,[Total Available Quantity (Damaged)] = [Damaged_Total_Available_Quantity]
      ,[Average Cost (Damaged)] = [Damaged_Average_Cost]
      ,[On Hand Quantity (Damaged But Available)] = [Damaged_But_Available_On_Hand_Quantity]
      ,[Reserved On Hand Quantity (Damaged But Available)] = [Damaged_But_Available_Reserved_On_Hand_Quantity]
      ,[Available On Hand Quantity (Damaged But Available)] = [Damaged_But_Available_Available_On_Hand_Quantity]
      ,[Ordered Quantiity (Damaged But Available)] = [Damaged_But_Available_Ordered_Quantiity]
      ,[Reserved Ordered Quantity (Damaged But Available)] = [Damaged_But_Available_Reserved_Ordered_Quantity]
      ,[Available Ordered Quantity (Damaged But Available)] = [Damaged_But_Available_Available_Ordered_Quantity]
      ,[On Order Quantity (Damaged But Available)] = [Damaged_But_Available_On_Order_Quantity]
      ,[Total Available Quantity (Damaged But Available)] = [Damaged_But_Available_Total_Available_Quantity]
      ,[Average Cost (Damaged But Available)] = [Damaged_But_Available_Average_Cost]
      ,[On Hand Quantity (Receipt Hold)] = [Receipt_Hold_On_Hand_Quantity]
      ,[Reserved On Hand Quantity (Receipt Hold)] = [Receipt_Hold_Reserved_On_Hand_Quantity]
      ,[Available On Hand Quantity (Receipt Hold)] = [Receipt_Hold_Available_On_Hand_Quantity]
      ,[Ordered Quantity (Receipt Hold)] = [Receipt_Hold_Ordered_Quantiity] --<=Typo
      ,[Reserved Ordered Quantity (Receipt Hold)] = [Receipt_Hold_Reserved_Ordered_Quantity]
      ,[Available Ordered_Quantity (Receipt Hold)] = [Receipt_Hold_Available_Ordered_Quantity]
      ,[On Order Quantity (Receipt Hold)] = [Receipt_Hold_On_Order_Quantity]
      ,[Total Available Quantity (Receipt Hold)] = [Receipt_Hold_Total_Available_Quantity]
      ,[Average Cost (Receipt Hold)] = [Receipt_Hold_Average_Cost]
      --,[Temporary_On_Hand_Quantity]
      --,[Temporary_Reserved_On_Hand_Quantity]
      --,[Temporary_Available_On_Hand_Quantity]
      --,[Temporary_Ordered_Quantiity]
      --,[Temporary_Reserved_Ordered_Quantity]
      --,[Temporary_Available_Ordered_Quantity]
      --,[Temporary_On_Order_Quantity]
      --,[Temporary_Total_Available_Quantity]
      --,[Temporary_Average_Cost]
      ,[On Hand Quantity (Warehouse Damage)] = [Warehouse_Damage_On_Hand_Quantity]
      ,[Reserved On Hand Quantity (Warehouse Damage)] = [Warehouse_Damage_Reserved_On_Hand_Quantity]
      ,[Available On Hand Quantity (Warehouse Damage)] = [Warehouse_Damage_Available_On_Hand_Quantity]
      ,[Ordered Quantiity (Warehouse Damage)] = [Warehouse_Damage_Ordered_Quantiity]
      ,[Reserved Ordered Quantity (Warehouse Damage)] = [Warehouse_Damage_Reserved_Ordered_Quantity]
      ,[Available Ordered Quantity (Warehouse Damage)] = [Warehouse_Damage_Available_Ordered_Quantity]
      ,[On Order Quantity (Warehouse Damage)] = [Warehouse_Damage_On_Order_Quantity]
      ,[Total Available Quantity (Warehouse Damage)] = [Warehouse_Damage_Total_Available_Quantity]
      ,[Average Cost (Warehouse Damage)] = [Warehouse_Damage_Average_Cost]
      --,[Blocking_On_Hand_Quantity]
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
	  ,[Extended Cost On Hand] = [Extended_Cost_On_Hand]
	  ,[Extended Cost On Order] = [Extended_Cost_On_Order]
	  ,[WMS On Hand Quantity (Available)] = i.Available_WMS_On_Hand_Quantity
	  --,[Receipt Hold WMS On Hand Quantity] = i.Receipt_Hold_Available_WMS_On_Hand_Quantity

  FROM [CWC_DW].[Fact].[Inventory] (NOLOCK) i
  LEFT JOIN [CWC_DW].[Dimension].[Inventory_Warehouses] (NOLOCK) iw ON i.Inventory_Warehouse_Key = iw.Inventory_Warehouse_Key
  WHERE i.Snapshot_Date_Key = (SELECT MAX(Snapshot_Date_Key) FROM [CWC_DW].[Fact].[Inventory] (NOLOCK))
  AND [is_Excluded] = 0 AND is_Removed_From_Source = 0 AND iw.Inventory_Warehouse = 'Distribution Center';

