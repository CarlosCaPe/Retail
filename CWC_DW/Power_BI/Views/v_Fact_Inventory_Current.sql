





/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Power_BI].[v_Fact_Inventory_Current]

AS

SELECT --[Snapshot_Date_Key]
       i.[Product_Key]
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
  --SELECT COUNT(*)
  FROM [CWC_DW].[Fact].[Inventory] (NOLOCK) i
  LEFT JOIN [CWC_DW].[Dimension].[Inventory_Warehouses] (NOLOCK) iw ON i.Inventory_Warehouse_Key = iw.Inventory_Warehouse_Key
  --INNER JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON i.Product_Key = p.Product_Key
  WHERE i.Snapshot_Date_Key = (SELECT MAX(Snapshot_Date_Key) FROM [CWC_DW].[Fact].[Inventory] (NOLOCK))
  AND Inventory_Warehouse IN (/*'Distribution Center',*/'XB')
  AND i.[is_Excluded] = 0 
  AND i.is_Removed_From_Source = 0

  --UNION ALL

  --SELECT --[Snapshot_Date_Key]
  --     p.[Product_Key]
  --    --,[Inventory_Warehouse_Key] = CAST(i.[Inventory_Warehouse_Key] AS SMALLINT)
	 -- ,[Inventory Warehouse] = 'Distribution Center'
	 -- --,iw.Inventory_Warehouse_ID
  --    ,[On Hand Quantity (Available)] = NULL
  --    ,[Reserved On Hand Quantity (Available)] = NULL
  --    ,[Available On Hand Quantity (Available)] = NULL
  --    ,[Ordered Quantiity (Available)] = NULL
  --    ,[Reserved_Ordered_Quantity (Available)] = NULL
  --    ,[Available Ordered Quantity (Available)] = NULL
  --    ,[On Order Quantity (Available)] = NULL
  --    ,[Total Available Quantity (Available)] = NULL
  --    ,[Average Cost (Available)] = NULL
  --    ,[On Hand Quantity (Returns)] = NULL
  --    ,[Reserved On Hand Quantity (Returns)] = NULL
  --    ,[Available On Hand Quantity (Returns)] = NULL
  --    ,[Ordered Quantiity (Returns)] = NULL
  --    ,[Reserved Ordered Quantity (Returns)] = NULL
  --    ,[Available Ordered Quantity (Returns)] = NULL
  --    ,[On Order Quantity (Returns)] = NULL
  --    ,[Total Available Quantity (Returns)] = NULL
  --    ,[Average Cost (Returns)] = NULL
  --    ,[On Hand Quantity (Damaged)] = NULL
  --    ,[Reserved On Hand Quantity (Damaged)] = NULL
  --    ,[Available On Hand Quantity (Damaged)] = NULL
  --    ,[Ordered Quantiity (Damaged)] = NULL
  --    ,[Reserved Ordered Quantity (Damaged)] = NULL
  --    ,[Available Ordered Quantity (Damaged)] = NULL
  --    ,[On Order Quantity (Damaged)] = NULL
  --    ,[Total Available Quantity (Damaged)] = NULL
  --    ,[Average Cost (Damaged)] = NULL
  --    ,[On Hand Quantity (Damaged But Available)] = NULL
  --    ,[Reserved On Hand Quantity (Damaged But Available)] = NULL
  --    ,[Available On Hand Quantity (Damaged But Available)] = NULL
  --    ,[Ordered Quantiity (Damaged But Available)] = NULL
  --    ,[Reserved Ordered Quantity (Damaged But Available)] = NULL
  --    ,[Available Ordered Quantity (Damaged But Available)] = NULL
  --    ,[On Order Quantity (Damaged But Available)] = NULL
  --    ,[Total Available Quantity (Damaged But Available)] = NULL
  --    ,[Average Cost (Damaged But Available)] = NULL
  --    ,[On Hand Quantity (Receipt Hold)] = NULL
  --    ,[Reserved On Hand Quantity (Receipt Hold)] = NULL
  --    ,[Available On Hand Quantity (Receipt Hold)] = NULL
  --    ,[Ordered Quantity (Receipt Hold)] = NULL --<=Typo
  --    ,[Reserved Ordered Quantity (Receipt Hold)] = NULL
  --    ,[Available Ordered_Quantity (Receipt Hold)] = NULL
  --    ,[On Order Quantity (Receipt Hold)] = NULL
  --    ,[Total Available Quantity (Receipt Hold)] = NULL
  --    ,[Average Cost (Receipt Hold)] = NULL
  --    --,[Temporary_On_Hand_Quantity]
  --    --,[Temporary_Reserved_On_Hand_Quantity]
  --    --,[Temporary_Available_On_Hand_Quantity]
  --    --,[Temporary_Ordered_Quantiity]
  --    --,[Temporary_Reserved_Ordered_Quantity]
  --    --,[Temporary_Available_Ordered_Quantity]
  --    --,[Temporary_On_Order_Quantity]
  --    --,[Temporary_Total_Available_Quantity]
  --    --,[Temporary_Average_Cost]
  --    ,[On Hand Quantity (Warehouse Damage)] = NULL
  --    ,[Reserved On Hand Quantity (Warehouse Damage)] = NULL
  --    ,[Available On Hand Quantity (Warehouse Damage)] = NULL
  --    ,[Ordered Quantiity (Warehouse Damage)] = NULL
  --    ,[Reserved Ordered Quantity (Warehouse Damage)] = NULL
  --    ,[Available Ordered Quantity (Warehouse Damage)] = NULL
  --    ,[On Order Quantity (Warehouse Damage)] = NULL
  --    ,[Total Available Quantity (Warehouse Damage)] = NULL
  --    ,[Average Cost (Warehouse Damage)] = NULL
  --    --,[Blocking_On_Hand_Quantity]
  --    --,[Blocking_Reserved_On_Hand_Quantity]
  --    --,[Blocking_Available_On_Hand_Quantity]
  --    --,[Blocking_Ordered_Quantiity]
  --    --,[Blocking_Reserved_Ordered_Quantity]
  --    --,[Blocking_Available_Ordered_Quantity]
  --    --,[Blocking_On_Order_Quantity]
  --    --,[Blocking_Total_Available_Quantity]
  --    --,[Blocking_Average_Cost]
  --    --,[General_Quarantine_On_Hand_Quantity]
  --    --,[General_Quarantine_Reserved_On_Hand_Quantity]
  --    --,[General_Quarantine_Available_On_Hand_Quantity]
  --    --,[General_Quarantine_Ordered_Quantiity]
  --    --,[General_Quarantine_Reserved_Ordered_Quantity]
  --    --,[General_Quarantine_Available_Ordered_Quantity]
  --    --,[General_Quarantine_On_Order_Quantity]
  --    --,[General_Quarantine_Total_Available_Quantity]
  --    --,[General_Quarantine_Average_Cost]
  --    --,[is_Removed_From_Source]
  --    --,[is_Excluded]
  --    --,[ETL_Created_Date]
  --    --,[ETL_Modified_Date]
  --    --,[ETL_Modified_Count]
	 -- ,[Extended Cost On Hand] = NULL
	 -- ,[Extended Cost On Order] = NULL
  ----SELECT COUNT(*)
  --FROM [CWC_DW].[Dimension].[Products] (NOLOCK) p 
	 -- LEFT JOIN [CWC_DW].[Fact].[Inventory] (NOLOCK) i ON i.Product_Key = p.Product_Key AND i.Inventory_Warehouse_Key = (SELECT [Inventory_Warehouse_Key] FROM [CWC_DW].[Analytics].[v_Dim_Inventory_Warehouses] WHERE Inventory_Warehouse = 'Distribution Center')
	 -- AND i.Snapshot_Date_Key = (SELECT MAX(Snapshot_Date_Key) FROM [CWC_DW].[Fact].[Inventory] (NOLOCK))
	 -- --LEFT JOIN [CWC_DW].[Dimension].[Inventory_Warehouses] (NOLOCK) iw ON i.Inventory_Warehouse_Key = iw.Inventory_Warehouse_Key
  --WHERE i.Product_Key IS NULL
  ;

