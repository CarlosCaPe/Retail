/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW Power_BI.v_Product_Inventory_Top20_Diff

AS

SELECT TOP (20) 
	 [Product Key] = i.[Product_Key]
	,p.[Item Number]
	,p.[Item Number Name]
	,p.[Item]
	,p.[Color ID]
	,p.Color
	,p.[Size ID]
	,p.Size
	,p.[Product Varient Number]
	,[Absolute Diff] = ABS(i.[Available_On_Hand_Quantity] - ISNULL(iy.[Available_On_Hand_Quantity],0))
	,[Available On Hand Quantity Diff] = i.[Available_On_Hand_Quantity] - iy.[Available_On_Hand_Quantity]
	--,[Available_Reserved_On_Hand_Quantity_Diff] = i.[Available_Reserved_On_Hand_Quantity] - iy.[Available_Reserved_On_Hand_Quantity]
 --   ,[Available_Available_On_Hand_Quantity_Diff] = i.[Available_Available_On_Hand_Quantity] - iy.[Available_Available_On_Hand_Quantity]
 --   ,[Available_Ordered_Quantiity_Diff] = i.[Available_Ordered_Quantiity] - iy.[Available_Ordered_Quantiity]
 --   ,[Available_Reserved_Ordered_Quantity_DIff] = i.[Available_Reserved_Ordered_Quantity] - iy.[Available_Reserved_Ordered_Quantity]
 --   ,[Available_Available_Ordered_Quantity_Diff] = i.[Available_Available_Ordered_Quantity] - iy.[Available_Available_Ordered_Quantity]
 --   ,[Available_On_Order_Quantity_Diff] = i.[Available_On_Order_Quantity] - iy.[Available_On_Order_Quantity]
 --   ,[Available_Total_Available_Quantity_Diff] = i.[Available_Total_Available_Quantity] - iy.[Available_Total_Available_Quantity]
--INTO  #INV_Diff
FROM [CWC_DW].[Fact].[Inventory] (NOLOCK) i
	INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Products] p ON i.Product_Key = p.[Product Key]
	INNER JOIN [CWC_DW].[Dimension].[Dates] d (NOLOCK) ON i.[Snapshot_Date_Key] = d.[Date_Key]
	INNER JOIN [CWC_DW].[Dimension].[Dates] dy (NOLOCK) ON DATEADD(WEEK,-1,d.Calendar_Date) = dy.Calendar_Date
	LEFT JOIN [CWC_DW].[Fact].[Inventory] (NOLOCK) iy ON iy.Snapshot_Date_Key = dy.Date_Key AND i.Product_Key = iy.Product_Key AND i.Inventory_Warehouse_Key = iy.Inventory_Warehouse_Key
WHERE d.is_Current_Inventory_Date = 1 AND i.Inventory_Warehouse_Key = 32
ORDER BY  ABS(i.[Available_On_Hand_Quantity] - iy.[Available_On_Hand_Quantity]) DESC;

--DBCC SHRINKDATABASE (CWC_DW, 10)