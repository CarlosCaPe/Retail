
CREATE PROC [Import].[usp_Fact_Inventory_Merge]

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

BEGIN TRY

		DECLARE @Snapshot_Date INT= (SELECT Date_Key FROM Dimension.Dates WHERE Calendar_Date = CAST(GETDATE() - 1 AS DATE));

		WITH Product_List AS
		(
			SELECT DISTINCT
			 p.Product_Key
			 ,w.Inventory_Warehouse_Key
			 ,w.Inventory_Warehouse_ID
			,p.SKU
			,p.Item_ID
			,p.Color_ID
			,p.Size_ID
			FROM [AX_PRODUCTION].[dbo].[ITSInventWarehouseInventoryStatusOnHandStaging] its
			INNER JOIN CWC_DW.Dimension.Products p ON its.PRODUCTCOLORID = p.Color_ID AND its.PRODUCTSIZEID = p.Size_ID AND its.ITEMNUMBER = p.Item_ID
			LEFT JOIN [CWC_DW].[Dimension].[Inventory_Warehouses] w ON ISNULL(NULLIF(its.INVENTORYWAREHOUSEID,''),'WHSE01') = w.[Inventory_Warehouse_ID]
		)
		,AV AS
		(
		 SELECT
			   [Product_Key] = p.Product_Key
			  ,[Inventory_Warehouse_Key] = p.Inventory_Warehouse_Key
			  ,[Available_On_Hand_Quantity] = its.[ONHANDQUANTITY]
			  ,[Available_Reserved_On_Hand_Quantity] = its.[RESERVEDONHANDQUANTITY]
			  ,[Available_Available_On_Hand_Quantity] = its.[AVAILABLEONHANDQUANTITY]
			  ,[Available_Ordered_Quantiity] = its.[OrderedQUANTITY]
			  ,[Available_Reserved_Ordered_Quantity] = its.[RESERVEDOrderedQUANTITY]
			  ,[Available_Available_Ordered_Quantity] = its.[AVAILABLEOrderedQUANTITY]
			  ,[Available_On_Order_Quantity] = its.[ONORDERQUANTITY]
			  ,[Available_Total_Available_Quantity] = its.[TOTALAVAILABLEQUANTITY]
			  ,[Available_Average_Cost] = its.[AVERAGECOST]

			  ,[Available_WMS_On_Hand_Quantity] = wms.ON_HAND_QTY

		FROM [AX_PRODUCTION].[dbo].[ITSInventWarehouseInventoryStatusOnHandStaging] its
			INNER JOIN Product_List p ON its.PRODUCTCOLORID = p.Color_ID AND its.PRODUCTSIZEID = p.Size_ID AND its.ITEMNUMBER = p.Item_ID AND p.Inventory_Warehouse_ID = its.INVENTORYWAREHOUSEID
			LEFT JOIN [WMS_INV].[dbo].[FACT_WMS_INVENTORY]   wms ON wms.[PRODUCTVARIANTNUMBER] = p.SKU AND wms.WAREHOUSE_ID = p.Inventory_Warehouse_ID AND wms.INVENTORY_STATUS_ID =its.INVENTORYSTATUSID
		WHERE [INVENTORYSTATUSID] = 'AV'
		) 
		, DA AS
		(
		 SELECT
			   [Product_Key] = p.Product_Key
			  ,[Inventory_Warehouse_Key] = p.Inventory_Warehouse_Key
			  ,[Damaged_But_Available_On_Hand_Quantity] = its.[ONHANDQUANTITY]
			  ,[Damaged_But_Available_Reserved_On_Hand_Quantity] = its.[RESERVEDONHANDQUANTITY]
			  ,[Damaged_But_Available_Available_On_Hand_Quantity] = its.[AVAILABLEONHANDQUANTITY]
			  ,[Damaged_But_Available_Ordered_Quantiity] = its.[OrderedQUANTITY]
			  ,[Damaged_But_Available_Reserved_Ordered_Quantity] = its.[RESERVEDOrderedQUANTITY]
			  ,[Damaged_But_Available_Available_Ordered_Quantity] = its.[AVAILABLEOrderedQUANTITY]
			  ,[Damaged_But_Available_On_Order_Quantity] = its.[ONORDERQUANTITY]
			  ,[Damaged_But_Available_Total_Available_Quantity] = its.[TOTALAVAILABLEQUANTITY]
			  ,[Damaged_But_Available_Average_Cost] = its.[AVERAGECOST]
      
			  ,[Damaged_But_Available_WMS_On_Hand_Quantity] = wms.ON_HAND_QTY

		FROM [AX_PRODUCTION].[dbo].[ITSInventWarehouseInventoryStatusOnHandStaging] its
		INNER JOIN Product_List p ON its.PRODUCTCOLORID = p.Color_ID AND its.PRODUCTSIZEID = p.Size_ID AND its.ITEMNUMBER = p.Item_ID AND p.Inventory_Warehouse_ID = its.INVENTORYWAREHOUSEID
		LEFT JOIN [WMS_INV].[dbo].[FACT_WMS_INVENTORY]   wms ON wms.[PRODUCTVARIANTNUMBER] = p.SKU AND wms.WAREHOUSE_ID = p.Inventory_Warehouse_ID AND wms.INVENTORY_STATUS_ID =its.INVENTORYSTATUSID
		WHERE [INVENTORYSTATUSID] = 'DA'
		)
		,BL AS
		(
		 SELECT
			   [Product_Key] = p.Product_Key
			  ,[Inventory_Warehouse_Key] = p.Inventory_Warehouse_Key
			  ,[Blocking_On_Hand_Quantity] = its.[ONHANDQUANTITY]
			  ,[Blocking_Reserved_On_Hand_Quantity] = its.[RESERVEDONHANDQUANTITY]
			  ,[Blocking_Available_On_Hand_Quantity] = its.[AVAILABLEONHANDQUANTITY]
			  ,[Blocking_Ordered_Quantiity] = its.[OrderedQUANTITY]
			  ,[Blocking_Reserved_Ordered_Quantity] = its.[RESERVEDOrderedQUANTITY]
			  ,[Blocking_Available_Ordered_Quantity] = its.[AVAILABLEOrderedQUANTITY]
			  ,[Blocking_On_Order_Quantity] = its.[ONORDERQUANTITY]
			  ,[Blocking_Total_Available_Quantity] = its.[TOTALAVAILABLEQUANTITY]
			  ,[Blocking_Average_Cost] = its.[AVERAGECOST]
			  ,[Blocking_WMS_On_Hand_Quantity] = wms.ON_HAND_QTY
		FROM [AX_PRODUCTION].[dbo].[ITSInventWarehouseInventoryStatusOnHandStaging] its
		INNER JOIN Product_List p ON its.PRODUCTCOLORID = p.Color_ID AND its.PRODUCTSIZEID = p.Size_ID AND its.ITEMNUMBER = p.Item_ID AND p.Inventory_Warehouse_ID = its.INVENTORYWAREHOUSEID
		LEFT JOIN [WMS_INV].[dbo].[FACT_WMS_INVENTORY]   wms ON wms.[PRODUCTVARIANTNUMBER] = p.SKU AND wms.WAREHOUSE_ID = p.Inventory_Warehouse_ID AND wms.INVENTORY_STATUS_ID =its.INVENTORYSTATUSID
		WHERE [INVENTORYSTATUSID] = 'BL'
		) 
		,DM AS
		(
		 SELECT
			   [Product_Key] = p.Product_Key
			  ,[Inventory_Warehouse_Key] = p.Inventory_Warehouse_Key
			  ,[Damaged_On_Hand_Quantity] = its.[ONHANDQUANTITY]
			  ,[Damaged_Reserved_On_Hand_Quantity] = its.[RESERVEDONHANDQUANTITY]
			  ,[Damaged_Available_On_Hand_Quantity] = its.[AVAILABLEONHANDQUANTITY]
			  ,[Damaged_Ordered_Quantiity] = its.[OrderedQUANTITY]
			  ,[Damaged_Reserved_Ordered_Quantity] = its.[RESERVEDOrderedQUANTITY]
			  ,[Damaged_Available_Ordered_Quantity] = its.[AVAILABLEOrderedQUANTITY]
			  ,[Damaged_On_Order_Quantity] = its.[ONORDERQUANTITY]
			  ,[Damaged_Total_Available_Quantity] = its.[TOTALAVAILABLEQUANTITY]
			  ,[Damaged_Average_Cost] = its.[AVERAGECOST]
      
			  ,[Damaged_WMS_On_Hand_Quantity] = wms.ON_HAND_QTY
		FROM [AX_PRODUCTION].[dbo].[ITSInventWarehouseInventoryStatusOnHandStaging] its
			INNER JOIN Product_List p ON its.PRODUCTCOLORID = p.Color_ID AND its.PRODUCTSIZEID = p.Size_ID AND its.ITEMNUMBER = p.Item_ID AND p.Inventory_Warehouse_ID = its.INVENTORYWAREHOUSEID
			LEFT JOIN [WMS_INV].[dbo].[FACT_WMS_INVENTORY]   wms ON wms.[PRODUCTVARIANTNUMBER] = p.SKU AND wms.WAREHOUSE_ID = p.Inventory_Warehouse_ID AND wms.INVENTORY_STATUS_ID =its.INVENTORYSTATUSID
		WHERE [INVENTORYSTATUSID] = 'DM'
		)
		,GQ AS
		(
		 SELECT
			   [Product_Key] = p.Product_Key
			  ,[Inventory_Warehouse_Key] = p.Inventory_Warehouse_Key
			  ,[General_Quarantine_On_Hand_Quantity] = its.[ONHANDQUANTITY]
			  ,[General_Quarantine_Reserved_On_Hand_Quantity] = its.[RESERVEDONHANDQUANTITY]
			  ,[General_Quarantine_Available_On_Hand_Quantity] = its.[AVAILABLEONHANDQUANTITY]
			  ,[General_Quarantine_Ordered_Quantiity] = its.[OrderedQUANTITY]
			  ,[General_Quarantine_Reserved_Ordered_Quantity] = its.[RESERVEDOrderedQUANTITY]
			  ,[General_Quarantine_Available_Ordered_Quantity] = its.[AVAILABLEOrderedQUANTITY]
			  ,[General_Quarantine_On_Order_Quantity] = its.[ONORDERQUANTITY]
			  ,[General_Quarantine_Total_Available_Quantity] = its.[TOTALAVAILABLEQUANTITY]
			  ,[General_Quarantine_Average_Cost] = its.[AVERAGECOST]
      
			  ,[General_Quarantine_WMS_On_Hand_Quantity] = wms.ON_HAND_QTY
		FROM [AX_PRODUCTION].[dbo].[ITSInventWarehouseInventoryStatusOnHandStaging] its
			INNER JOIN Product_List p ON its.PRODUCTCOLORID = p.Color_ID AND its.PRODUCTSIZEID = p.Size_ID AND its.ITEMNUMBER = p.Item_ID AND p.Inventory_Warehouse_ID = its.INVENTORYWAREHOUSEID
			LEFT JOIN [WMS_INV].[dbo].[FACT_WMS_INVENTORY]   wms ON wms.[PRODUCTVARIANTNUMBER] = p.SKU AND wms.WAREHOUSE_ID = p.Inventory_Warehouse_ID AND wms.INVENTORY_STATUS_ID =its.INVENTORYSTATUSID
		WHERE [INVENTORYSTATUSID] = 'GQ'
		)
		,RH AS
		(
		 SELECT
			   [Product_Key] = p.Product_Key
			  ,[Inventory_Warehouse_Key] = p.Inventory_Warehouse_Key
			  ,[Receipt_Hold_On_Hand_Quantity] = its.[ONHANDQUANTITY]
			  ,[Receipt_Hold_Reserved_On_Hand_Quantity] = its.[RESERVEDONHANDQUANTITY]
			  ,[Receipt_Hold_Available_On_Hand_Quantity] = its.[AVAILABLEONHANDQUANTITY]
			  ,[Receipt_Hold_Ordered_Quantiity] = its.[OrderedQUANTITY]
			  ,[Receipt_Hold_Reserved_Ordered_Quantity] = its.[RESERVEDOrderedQUANTITY]
			  ,[Receipt_Hold_Available_Ordered_Quantity] = its.[AVAILABLEOrderedQUANTITY]
			  ,[Receipt_Hold_On_Order_Quantity] = its.[ONORDERQUANTITY]
			  ,[Receipt_Hold_Total_Available_Quantity] = its.[TOTALAVAILABLEQUANTITY]
			  ,[Receipt_Hold_Average_Cost] = its.[AVERAGECOST]
      
			  ,[Receipt_Hold_WMS_On_Hand_Quantity] = wms.ON_HAND_QTY
		FROM [AX_PRODUCTION].[dbo].[ITSInventWarehouseInventoryStatusOnHandStaging] its
		INNER JOIN Product_List p ON its.PRODUCTCOLORID = p.Color_ID AND its.PRODUCTSIZEID = p.Size_ID AND its.ITEMNUMBER = p.Item_ID AND p.Inventory_Warehouse_ID = its.INVENTORYWAREHOUSEID
		LEFT JOIN [WMS_INV].[dbo].[FACT_WMS_INVENTORY]   wms ON wms.[PRODUCTVARIANTNUMBER] = p.SKU AND wms.WAREHOUSE_ID = p.Inventory_Warehouse_ID AND wms.INVENTORY_STATUS_ID =its.INVENTORYSTATUSID
		WHERE [INVENTORYSTATUSID] = 'RH'
		)
		,RT AS
		(
		 SELECT
			   [Product_Key] = p.Product_Key
			  ,[Inventory_Warehouse_Key] = p.Inventory_Warehouse_Key
			  ,[Returns_On_Hand_Quantity] = its.[ONHANDQUANTITY]
			  ,[Returns_Reserved_On_Hand_Quantity] = its.[RESERVEDONHANDQUANTITY]
			  ,[Returns_Available_On_Hand_Quantity] = its.[AVAILABLEONHANDQUANTITY]
			  ,[Returns_Ordered_Quantiity] = its.[OrderedQUANTITY]
			  ,[Returns_Reserved_Ordered_Quantity] = its.[RESERVEDOrderedQUANTITY]
			  ,[Returns_Available_Ordered_Quantity] = its.[AVAILABLEOrderedQUANTITY]
			  ,[Returns_On_Order_Quantity] = its.[ONORDERQUANTITY]
			  ,[Returns_Total_Available_Quantity] = its.[TOTALAVAILABLEQUANTITY]
			  ,[Returns_Average_Cost] = its.[AVERAGECOST]
      
			  ,[Returns_WMS_On_Hand_Quantity] = wms.ON_HAND_QTY
		FROM [AX_PRODUCTION].[dbo].[ITSInventWarehouseInventoryStatusOnHandStaging] its
		INNER JOIN Product_List p ON its.PRODUCTCOLORID = p.Color_ID AND its.PRODUCTSIZEID = p.Size_ID AND its.ITEMNUMBER = p.Item_ID AND p.Inventory_Warehouse_ID = its.INVENTORYWAREHOUSEID
		LEFT JOIN [WMS_INV].[dbo].[FACT_WMS_INVENTORY]   wms ON wms.[PRODUCTVARIANTNUMBER] = p.SKU AND wms.WAREHOUSE_ID = p.Inventory_Warehouse_ID AND wms.INVENTORY_STATUS_ID =its.INVENTORYSTATUSID
		WHERE [INVENTORYSTATUSID] = 'RT'
		)
		,SU AS
		(
		 SELECT
			   [Product_Key] = p.Product_Key
			  ,[Inventory_Warehouse_Key] = p.Inventory_Warehouse_Key
			  ,[Temporary_On_Hand_Quantity] = its.[ONHANDQUANTITY]
			  ,[Temporary_Reserved_On_Hand_Quantity] = its.[RESERVEDONHANDQUANTITY]
			  ,[Temporary_Available_On_Hand_Quantity] = its.[AVAILABLEONHANDQUANTITY]
			  ,[Temporary_Ordered_Quantiity] = its.[OrderedQUANTITY]
			  ,[Temporary_Reserved_Ordered_Quantity] = its.[RESERVEDOrderedQUANTITY]
			  ,[Temporary_Available_Ordered_Quantity] = its.[AVAILABLEOrderedQUANTITY]
			  ,[Temporary_On_Order_Quantity] = its.[ONORDERQUANTITY]
			  ,[Temporary_Total_Available_Quantity] = its.[TOTALAVAILABLEQUANTITY]
			  ,[Temporary_Average_Cost] = its.[AVERAGECOST]
      
			  ,[Temporary_WMS_On_Hand_Quantity] = wms.ON_HAND_QTY
		FROM [AX_PRODUCTION].[dbo].[ITSInventWarehouseInventoryStatusOnHandStaging] its
			INNER JOIN Product_List p ON its.PRODUCTCOLORID = p.Color_ID AND its.PRODUCTSIZEID = p.Size_ID AND its.ITEMNUMBER = p.Item_ID AND p.Inventory_Warehouse_ID = its.INVENTORYWAREHOUSEID
			LEFT JOIN [WMS_INV].[dbo].[FACT_WMS_INVENTORY]   wms ON wms.[PRODUCTVARIANTNUMBER] = p.SKU AND wms.WAREHOUSE_ID = p.Inventory_Warehouse_ID AND wms.INVENTORY_STATUS_ID =its.INVENTORYSTATUSID
		WHERE [INVENTORYSTATUSID] = 'SU'
		)
		,WD AS
		(
		 SELECT
			   [Product_Key] = p.Product_Key
			  ,[Inventory_Warehouse_Key] = p.Inventory_Warehouse_Key
			  ,[Warehouse_Damage_On_Hand_Quantity] = its.[ONHANDQUANTITY]
			  ,[Warehouse_Damage_Reserved_On_Hand_Quantity] = its.[RESERVEDONHANDQUANTITY]
			  ,[Warehouse_Damage_Available_On_Hand_Quantity] = its.[AVAILABLEONHANDQUANTITY]
			  ,[Warehouse_Damage_Ordered_Quantiity] = its.[OrderedQUANTITY]
			  ,[Warehouse_Damage_Reserved_Ordered_Quantity] = its.[RESERVEDOrderedQUANTITY]
			  ,[Warehouse_Damage_Available_Ordered_Quantity] = its.[AVAILABLEOrderedQUANTITY]
			  ,[Warehouse_Damage_On_Order_Quantity] = its.[ONORDERQUANTITY]
			  ,[Warehouse_Damage_Total_Available_Quantity] = its.[TOTALAVAILABLEQUANTITY]
			  ,[Warehouse_Damage_Average_Cost] = its.[AVERAGECOST]
      
			  ,[Warehouse_Damage_WMS_On_Hand_Quantity] = wms.ON_HAND_QTY
		FROM [AX_PRODUCTION].[dbo].[ITSInventWarehouseInventoryStatusOnHandStaging] its
			INNER JOIN Product_List p ON its.PRODUCTCOLORID = p.Color_ID AND its.PRODUCTSIZEID = p.Size_ID AND its.ITEMNUMBER = p.Item_ID AND p.Inventory_Warehouse_ID = its.INVENTORYWAREHOUSEID
			LEFT JOIN [WMS_INV].[dbo].[FACT_WMS_INVENTORY]   wms ON wms.[PRODUCTVARIANTNUMBER] = p.SKU AND wms.WAREHOUSE_ID = p.Inventory_Warehouse_ID AND wms.INVENTORY_STATUS_ID =its.INVENTORYSTATUSID
		WHERE [INVENTORYSTATUSID] = 'WD'
		)
		,src AS
		(
		SELECT
			 [Snapshot_Date_Key] = @Snapshot_Date
			,[Product_Key] = p.Product_Key
			,[Inventory_Warehouse_Key] = p.Inventory_Warehouse_Key
			--AV
			,[Available_On_Hand_Quantity] = ISNULL([Available_On_Hand_Quantity],0)
			,[Available_Reserved_On_Hand_Quantity] = ISNULL([Available_Reserved_On_Hand_Quantity],0)
			,[Available_Available_On_Hand_Quantity] = ISNULL([Available_Available_On_Hand_Quantity],0)
			,[Available_Ordered_Quantiity] = ISNULL([Available_Ordered_Quantiity],0)
			,[Available_Reserved_Ordered_Quantity] = ISNULL([Available_Reserved_Ordered_Quantity],0)
			,[Available_Available_Ordered_Quantity] = ISNULL([Available_Available_Ordered_Quantity],0)
			,[Available_On_Order_Quantity] = ISNULL([Available_On_Order_Quantity],0)
			,[Available_Total_Available_Quantity] = ISNULL([Available_Total_Available_Quantity],0)
			,[Available_Average_Cost] = ISNULL([Available_Average_Cost],0)
			,[Available_WMS_On_Hand_Quantity] = ISNULL([Available_WMS_On_Hand_Quantity],0)
			--RT
			,[Returns_On_Hand_Quantity] = ISNULL([Returns_On_Hand_Quantity],0)
			,[Returns_Reserved_On_Hand_Quantity] = ISNULL([Returns_Reserved_On_Hand_Quantity],0)
			,[Returns_Available_On_Hand_Quantity] = ISNULL([Returns_Available_On_Hand_Quantity],0)
			,[Returns_Ordered_Quantiity] = ISNULL([Returns_Ordered_Quantiity],0)
			,[Returns_Reserved_Ordered_Quantity] = ISNULL([Returns_Reserved_Ordered_Quantity],0)
			,[Returns_Available_Ordered_Quantity] = ISNULL([Returns_Available_Ordered_Quantity],0)
			,[Returns_On_Order_Quantity] = ISNULL([Returns_On_Order_Quantity],0)
			,[Returns_Total_Available_Quantity] = ISNULL([Returns_Total_Available_Quantity],0)
			,[Returns_Average_Cost] = ISNULL([Returns_Average_Cost],0)
			,[Returns_WMS_On_Hand_Quantity] = ISNULL([Returns_WMS_On_Hand_Quantity],0)
			--DM
			,[Damaged_On_Hand_Quantity] = ISNULL([Damaged_On_Hand_Quantity],0)
			,[Damaged_Reserved_On_Hand_Quantity] = ISNULL([Damaged_Reserved_On_Hand_Quantity],0)
			,[Damaged_Available_On_Hand_Quantity] = ISNULL([Damaged_Available_On_Hand_Quantity],0)
			,[Damaged_Ordered_Quantiity] = ISNULL([Damaged_Ordered_Quantiity],0)
			,[Damaged_Reserved_Ordered_Quantity] = ISNULL([Damaged_Reserved_Ordered_Quantity],0)
			,[Damaged_Available_Ordered_Quantity] = ISNULL([Damaged_Available_Ordered_Quantity],0)
			,[Damaged_On_Order_Quantity] = ISNULL([Damaged_On_Order_Quantity],0)
			,[Damaged_Total_Available_Quantity] = ISNULL([Damaged_Total_Available_Quantity],0)
			,[Damaged_Average_Cost] = ISNULL([Damaged_Average_Cost],0)
			,[Damaged_WMS_On_Hand_Quantity] = ISNULL([Damaged_WMS_On_Hand_Quantity],0)
			--DA
			,[Damaged_But_Available_On_Hand_Quantity] = ISNULL([Damaged_But_Available_On_Hand_Quantity],0)
			,[Damaged_But_Available_Reserved_On_Hand_Quantity] = ISNULL([Damaged_But_Available_Reserved_On_Hand_Quantity],0)
			,[Damaged_But_Available_Available_On_Hand_Quantity] = ISNULL([Damaged_But_Available_Available_On_Hand_Quantity],0)
			,[Damaged_But_Available_Ordered_Quantiity] = ISNULL([Damaged_But_Available_Ordered_Quantiity],0)
			,[Damaged_But_Available_Reserved_Ordered_Quantity] = ISNULL([Damaged_But_Available_Reserved_Ordered_Quantity],0)
			,[Damaged_But_Available_Available_Ordered_Quantity] = ISNULL([Damaged_But_Available_Available_Ordered_Quantity],0)
			,[Damaged_But_Available_On_Order_Quantity] = ISNULL([Damaged_But_Available_On_Order_Quantity],0)
			,[Damaged_But_Available_Total_Available_Quantity] = ISNULL([Damaged_But_Available_Total_Available_Quantity],0)
			,[Damaged_But_Available_Average_Cost] = ISNULL([Damaged_But_Available_Average_Cost],0)
			,[Damaged_But_Available_WMS_On_Hand_Quantity] = ISNULL([Damaged_But_Available_WMS_On_Hand_Quantity],0)
			--RH
			,[Receipt_Hold_On_Hand_Quantity] = ISNULL([Receipt_Hold_On_Hand_Quantity],0)
			,[Receipt_Hold_Reserved_On_Hand_Quantity] = ISNULL([Receipt_Hold_Reserved_On_Hand_Quantity],0)
			,[Receipt_Hold_Available_On_Hand_Quantity] = ISNULL([Receipt_Hold_Available_On_Hand_Quantity],0)
			,[Receipt_Hold_Ordered_Quantiity] = ISNULL([Receipt_Hold_Ordered_Quantiity],0)
			,[Receipt_Hold_Reserved_Ordered_Quantity] = ISNULL([Receipt_Hold_Reserved_Ordered_Quantity],0)
			,[Receipt_Hold_Available_Ordered_Quantity] = ISNULL([Receipt_Hold_Available_Ordered_Quantity],0)
			,[Receipt_Hold_On_Order_Quantity] = ISNULL([Receipt_Hold_On_Order_Quantity],0)
			,[Receipt_Hold_Total_Available_Quantity] = ISNULL([Receipt_Hold_Total_Available_Quantity],0)
			,[Receipt_Hold_Average_Cost] = ISNULL([Receipt_Hold_Average_Cost],0)
			,[Receipt_Hold_Available_WMS_On_Hand_Quantity] = ISNULL([Damaged_But_Available_WMS_On_Hand_Quantity],0)
			--SU
			,[Temporary_On_Hand_Quantity] = ISNULL([Temporary_On_Hand_Quantity],0)
			,[Temporary_Reserved_On_Hand_Quantity] = ISNULL([Temporary_Reserved_On_Hand_Quantity],0)
			,[Temporary_Available_On_Hand_Quantity] = ISNULL([Temporary_Available_On_Hand_Quantity],0)
			,[Temporary_Ordered_Quantiity] = ISNULL([Temporary_Ordered_Quantiity],0)
			,[Temporary_Reserved_Ordered_Quantity] = ISNULL([Temporary_Reserved_Ordered_Quantity],0)
			,[Temporary_Available_Ordered_Quantity] = ISNULL([Temporary_Available_Ordered_Quantity],0)
			,[Temporary_On_Order_Quantity] = ISNULL([Temporary_On_Order_Quantity],0)
			,[Temporary_Total_Available_Quantity] = ISNULL([Temporary_Total_Available_Quantity],0)
			,[Temporary_Average_Cost] = ISNULL([Temporary_Average_Cost],0)
			,[Temporary_WMS_On_Hand_Quantity] = ISNULL([Temporary_WMS_On_Hand_Quantity],0)
			--WD
			,[Warehouse_Damage_On_Hand_Quantity] = ISNULL([Warehouse_Damage_On_Hand_Quantity],0)
			,[Warehouse_Damage_Reserved_On_Hand_Quantity] = ISNULL([Warehouse_Damage_Reserved_On_Hand_Quantity],0)
			,[Warehouse_Damage_Available_On_Hand_Quantity] = ISNULL([Warehouse_Damage_Available_On_Hand_Quantity],0)
			,[Warehouse_Damage_Ordered_Quantiity] = ISNULL([Warehouse_Damage_Ordered_Quantiity],0)
			,[Warehouse_Damage_Reserved_Ordered_Quantity] = ISNULL([Warehouse_Damage_Reserved_Ordered_Quantity],0)
			,[Warehouse_Damage_Available_Ordered_Quantity] = ISNULL([Warehouse_Damage_Available_Ordered_Quantity],0)
			,[Warehouse_Damage_On_Order_Quantity] = ISNULL([Warehouse_Damage_On_Order_Quantity],0)
			,[Warehouse_Damage_Total_Available_Quantity] = ISNULL([Warehouse_Damage_Total_Available_Quantity],0)
			,[Warehouse_Damage_Average_Cost] = ISNULL([Warehouse_Damage_Average_Cost],0)
			,[Warehouse_Damage_WMS_On_Hand_Quantity] = ISNULL([Warehouse_Damage_WMS_On_Hand_Quantity],0)
			--BL
			,[Blocking_On_Hand_Quantity] = ISNULL([Blocking_On_Hand_Quantity],0)
			,[Blocking_Reserved_On_Hand_Quantity] = ISNULL([Blocking_Reserved_On_Hand_Quantity],0)
			,[Blocking_Available_On_Hand_Quantity] = ISNULL([Blocking_Available_On_Hand_Quantity],0)
			,[Blocking_Ordered_Quantiity] = ISNULL([Blocking_Ordered_Quantiity],0)
			,[Blocking_Reserved_Ordered_Quantity] = ISNULL([Blocking_Reserved_Ordered_Quantity],0)
			,[Blocking_Available_Ordered_Quantity] = ISNULL([Blocking_Available_Ordered_Quantity],0)
			,[Blocking_On_Order_Quantity] = ISNULL([Blocking_On_Order_Quantity],0)
			,[Blocking_Total_Available_Quantity] = ISNULL([Blocking_Total_Available_Quantity],0)
			,[Blocking_Average_Cost] = ISNULL([Blocking_Average_Cost],0)
			,[Blocking_WMS_On_Hand_Quantity] = ISNULL([Blocking_WMS_On_Hand_Quantity],0)
			--GQ
			,[General_Quarantine_On_Hand_Quantity] = ISNULL([General_Quarantine_On_Hand_Quantity],0)
			,[General_Quarantine_Reserved_On_Hand_Quantity] = ISNULL([General_Quarantine_Reserved_On_Hand_Quantity],0)
			,[General_Quarantine_Available_On_Hand_Quantity] = ISNULL([General_Quarantine_Available_On_Hand_Quantity],0)
			,[General_Quarantine_Ordered_Quantiity] = ISNULL([General_Quarantine_Ordered_Quantiity],0)
			,[General_Quarantine_Reserved_Ordered_Quantity] = ISNULL([General_Quarantine_Reserved_Ordered_Quantity],0)
			,[General_Quarantine_Available_Ordered_Quantity] = ISNULL([General_Quarantine_Available_Ordered_Quantity],0)
			,[General_Quarantine_On_Order_Quantity] = ISNULL([General_Quarantine_On_Order_Quantity],0)
			,[General_Quarantine_Total_Available_Quantity] = ISNULL([General_Quarantine_Total_Available_Quantity],0)
			,[General_Quarantine_Average_Cost] = ISNULL([General_Quarantine_Average_Cost],0)
			,[General_Quarantine_WMS_On_Hand_Quantity] = ISNULL([General_Quarantine_WMS_On_Hand_Quantity],0)
			--Admin
			,[is_Removed_From_Source] = CAST(0 AS BIT)
			,[is_Excluded] = CAST(0 AS BIT)
			,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Count] = CAST(1 AS TINYINT)
			--INTO Fact.Inventory
		FROM Product_List p
		LEFT JOIN AV on p.Product_Key = av.Product_Key AND p.Inventory_Warehouse_Key = av.Inventory_Warehouse_Key
		LEFT JOIN RT on p.Product_Key = rt.Product_Key AND p.Inventory_Warehouse_Key = rt.Inventory_Warehouse_Key
		LEFT JOIN DM on p.Product_Key = dm.Product_Key AND p.Inventory_Warehouse_Key = dm.Inventory_Warehouse_Key
		LEFT JOIN DA on p.Product_Key = da.Product_Key AND p.Inventory_Warehouse_Key = da.Inventory_Warehouse_Key
		LEFT JOIN RH on p.Product_Key = rh.Product_Key AND p.Inventory_Warehouse_Key = rh.Inventory_Warehouse_Key

		LEFT JOIN SU on p.Product_Key = su.Product_Key AND p.Inventory_Warehouse_Key = su.Inventory_Warehouse_Key
		LEFT JOIN WD on p.Product_Key = wd.Product_Key AND p.Inventory_Warehouse_Key = wd.Inventory_Warehouse_Key
		LEFT JOIN BL on p.Product_Key = bl.Product_Key AND p.Inventory_Warehouse_Key = bl.Inventory_Warehouse_Key
		LEFT JOIN GQ on p.Product_Key = gq.Product_Key AND p.Inventory_Warehouse_Key = gq.Inventory_Warehouse_Key
		) --SELECT * FROM src

		,tgt AS (SELECT * FROM [CWC_DW].[Fact].[Inventory] WHERE Snapshot_Date_Key = @Snapshot_Date)

		MERGE INTO tgt USING src
			ON  tgt.Snapshot_Date_Key = src.Snapshot_Date_Key 
			AND tgt.Product_Key = src.Product_Key 
			AND tgt.Inventory_Warehouse_Key = src.Inventory_Warehouse_Key
		WHEN NOT MATCHED THEN

		INSERT([Snapshot_Date_Key],[Product_Key],[Inventory_Warehouse_Key],[Available_On_Hand_Quantity],[Available_Reserved_On_Hand_Quantity],[Available_Available_On_Hand_Quantity],[Available_Ordered_Quantiity]
			  ,[Available_Reserved_Ordered_Quantity],[Available_Available_Ordered_Quantity],[Available_On_Order_Quantity],[Available_Total_Available_Quantity],[Available_Average_Cost],[Returns_On_Hand_Quantity]
			  ,[Returns_Reserved_On_Hand_Quantity],[Returns_Available_On_Hand_Quantity],[Returns_Ordered_Quantiity],[Returns_Reserved_Ordered_Quantity],[Returns_Available_Ordered_Quantity],[Returns_On_Order_Quantity]
			  ,[Returns_Total_Available_Quantity],[Returns_Average_Cost],[Damaged_On_Hand_Quantity],[Damaged_Reserved_On_Hand_Quantity],[Damaged_Available_On_Hand_Quantity],[Damaged_Ordered_Quantiity]
			  ,[Damaged_Reserved_Ordered_Quantity],[Damaged_Available_Ordered_Quantity],[Damaged_On_Order_Quantity],[Damaged_Total_Available_Quantity],[Damaged_Average_Cost],[Damaged_But_Available_On_Hand_Quantity]
			  ,[Damaged_But_Available_Reserved_On_Hand_Quantity],[Damaged_But_Available_Available_On_Hand_Quantity],[Damaged_But_Available_Ordered_Quantiity],[Damaged_But_Available_Reserved_Ordered_Quantity]
			  ,[Damaged_But_Available_Available_Ordered_Quantity],[Damaged_But_Available_On_Order_Quantity],[Damaged_But_Available_Total_Available_Quantity],[Damaged_But_Available_Average_Cost],[Receipt_Hold_On_Hand_Quantity]
			  ,[Receipt_Hold_Reserved_On_Hand_Quantity],[Receipt_Hold_Available_On_Hand_Quantity],[Receipt_Hold_Ordered_Quantiity],[Receipt_Hold_Reserved_Ordered_Quantity],[Receipt_Hold_Available_Ordered_Quantity]
			  ,[Receipt_Hold_On_Order_Quantity],[Receipt_Hold_Total_Available_Quantity],[Receipt_Hold_Average_Cost],[Temporary_On_Hand_Quantity],[Temporary_Reserved_On_Hand_Quantity],[Temporary_Available_On_Hand_Quantity]
			  ,[Temporary_Ordered_Quantiity],[Temporary_Reserved_Ordered_Quantity],[Temporary_Available_Ordered_Quantity],[Temporary_On_Order_Quantity],[Temporary_Total_Available_Quantity],[Temporary_Average_Cost]
			  ,[Warehouse_Damage_On_Hand_Quantity],[Warehouse_Damage_Reserved_On_Hand_Quantity],[Warehouse_Damage_Available_On_Hand_Quantity],[Warehouse_Damage_Ordered_Quantiity],[Warehouse_Damage_Reserved_Ordered_Quantity]
			  ,[Warehouse_Damage_Available_Ordered_Quantity],[Warehouse_Damage_On_Order_Quantity],[Warehouse_Damage_Total_Available_Quantity],[Warehouse_Damage_Average_Cost],[Blocking_On_Hand_Quantity],[Blocking_Reserved_On_Hand_Quantity]
			  ,[Blocking_Available_On_Hand_Quantity],[Blocking_Ordered_Quantiity],[Blocking_Reserved_Ordered_Quantity],[Blocking_Available_Ordered_Quantity],[Blocking_On_Order_Quantity],[Blocking_Total_Available_Quantity]
			  ,[Blocking_Average_Cost],[General_Quarantine_On_Hand_Quantity],[General_Quarantine_Reserved_On_Hand_Quantity],[General_Quarantine_Available_On_Hand_Quantity],[General_Quarantine_Ordered_Quantiity]
			  ,[General_Quarantine_Reserved_Ordered_Quantity],[General_Quarantine_Available_Ordered_Quantity],[General_Quarantine_On_Order_Quantity],[General_Quarantine_Total_Available_Quantity],[General_Quarantine_Average_Cost]
			  ,[is_Removed_From_Source],[is_Excluded],[ETL_Created_Date],[ETL_Modified_Date],[ETL_Modified_Count]
			  ,[Available_WMS_On_Hand_Quantity],[Returns_WMS_On_Hand_Quantity],[Damaged_WMS_On_Hand_Quantity],[Damaged_But_Available_WMS_On_Hand_Quantity],[Receipt_Hold_Available_WMS_On_Hand_Quantity]
			  ,[Temporary_WMS_On_Hand_Quantity],[Warehouse_Damage_WMS_On_Hand_Quantity],[Blocking_WMS_On_Hand_Quantity],[General_Quarantine_WMS_On_Hand_Quantity])

		VALUES(src.[Snapshot_Date_Key],src.[Product_Key],src.[Inventory_Warehouse_Key],src.[Available_On_Hand_Quantity],src.[Available_Reserved_On_Hand_Quantity],src.[Available_Available_On_Hand_Quantity],src.[Available_Ordered_Quantiity]
			  ,src.[Available_Reserved_Ordered_Quantity],src.[Available_Available_Ordered_Quantity],src.[Available_On_Order_Quantity],src.[Available_Total_Available_Quantity],src.[Available_Average_Cost],src.[Returns_On_Hand_Quantity]
			  ,src.[Returns_Reserved_On_Hand_Quantity],src.[Returns_Available_On_Hand_Quantity],src.[Returns_Ordered_Quantiity],src.[Returns_Reserved_Ordered_Quantity],src.[Returns_Available_Ordered_Quantity],src.[Returns_On_Order_Quantity]
			  ,src.[Returns_Total_Available_Quantity],src.[Returns_Average_Cost],src.[Damaged_On_Hand_Quantity],src.[Damaged_Reserved_On_Hand_Quantity],src.[Damaged_Available_On_Hand_Quantity],src.[Damaged_Ordered_Quantiity]
			  ,src.[Damaged_Reserved_Ordered_Quantity],src.[Damaged_Available_Ordered_Quantity],src.[Damaged_On_Order_Quantity],src.[Damaged_Total_Available_Quantity],src.[Damaged_Average_Cost],src.[Damaged_But_Available_On_Hand_Quantity]
			  ,src.[Damaged_But_Available_Reserved_On_Hand_Quantity],src.[Damaged_But_Available_Available_On_Hand_Quantity],src.[Damaged_But_Available_Ordered_Quantiity],src.[Damaged_But_Available_Reserved_Ordered_Quantity]
			  ,src.[Damaged_But_Available_Available_Ordered_Quantity],src.[Damaged_But_Available_On_Order_Quantity],src.[Damaged_But_Available_Total_Available_Quantity],src.[Damaged_But_Available_Average_Cost],src.[Receipt_Hold_On_Hand_Quantity]
			  ,src.[Receipt_Hold_Reserved_On_Hand_Quantity],src.[Receipt_Hold_Available_On_Hand_Quantity],src.[Receipt_Hold_Ordered_Quantiity],src.[Receipt_Hold_Reserved_Ordered_Quantity],src.[Receipt_Hold_Available_Ordered_Quantity]
			  ,src.[Receipt_Hold_On_Order_Quantity],src.[Receipt_Hold_Total_Available_Quantity],src.[Receipt_Hold_Average_Cost],src.[Temporary_On_Hand_Quantity],src.[Temporary_Reserved_On_Hand_Quantity],src.[Temporary_Available_On_Hand_Quantity]
			  ,src.[Temporary_Ordered_Quantiity],src.[Temporary_Reserved_Ordered_Quantity],src.[Temporary_Available_Ordered_Quantity],src.[Temporary_On_Order_Quantity],src.[Temporary_Total_Available_Quantity],src.[Temporary_Average_Cost]
			  ,src.[Warehouse_Damage_On_Hand_Quantity],src.[Warehouse_Damage_Reserved_On_Hand_Quantity],src.[Warehouse_Damage_Available_On_Hand_Quantity],src.[Warehouse_Damage_Ordered_Quantiity],src.[Warehouse_Damage_Reserved_Ordered_Quantity]
			  ,src.[Warehouse_Damage_Available_Ordered_Quantity],src.[Warehouse_Damage_On_Order_Quantity],src.[Warehouse_Damage_Total_Available_Quantity],src.[Warehouse_Damage_Average_Cost],src.[Blocking_On_Hand_Quantity],src.[Blocking_Reserved_On_Hand_Quantity]
			  ,src.[Blocking_Available_On_Hand_Quantity],src.[Blocking_Ordered_Quantiity],src.[Blocking_Reserved_Ordered_Quantity],src.[Blocking_Available_Ordered_Quantity],src.[Blocking_On_Order_Quantity],src.[Blocking_Total_Available_Quantity]
			  ,src.[Blocking_Average_Cost],src.[General_Quarantine_On_Hand_Quantity],src.[General_Quarantine_Reserved_On_Hand_Quantity],src.[General_Quarantine_Available_On_Hand_Quantity],src.[General_Quarantine_Ordered_Quantiity]
			  ,src.[General_Quarantine_Reserved_Ordered_Quantity],src.[General_Quarantine_Available_Ordered_Quantity],src.[General_Quarantine_On_Order_Quantity],src.[General_Quarantine_Total_Available_Quantity],src.[General_Quarantine_Average_Cost]
			  ,src.[is_Removed_From_Source],src.[is_Excluded],src.[ETL_Created_Date],src.[ETL_Modified_Date],src.[ETL_Modified_Count]
			  ,src.[Available_WMS_On_Hand_Quantity],src.[Returns_WMS_On_Hand_Quantity],src.[Damaged_WMS_On_Hand_Quantity],src.[Damaged_But_Available_WMS_On_Hand_Quantity],src.[Receipt_Hold_Available_WMS_On_Hand_Quantity]
			  ,src.[Temporary_WMS_On_Hand_Quantity],src.[Warehouse_Damage_WMS_On_Hand_Quantity],src.[Blocking_WMS_On_Hand_Quantity],src.[General_Quarantine_WMS_On_Hand_Quantity])
		WHEN MATCHED AND
				   ISNULL(tgt.[Available_On_Hand_Quantity],'') <> src.[Available_On_Hand_Quantity]
				OR ISNULL(tgt.[Available_Reserved_On_Hand_Quantity],'') <> src.[Available_Reserved_On_Hand_Quantity] 
				OR ISNULL(tgt.[Available_Available_On_Hand_Quantity],'') <> src.[Available_Available_On_Hand_Quantity] 
				OR ISNULL(tgt.[Available_Ordered_Quantiity],'') <> src.[Available_Ordered_Quantiity]
				OR ISNULL(tgt.[Available_Reserved_Ordered_Quantity],'') <> src.[Available_Reserved_Ordered_Quantity]
				OR ISNULL(tgt.[Available_Available_Ordered_Quantity],'') <> src.[Available_Available_Ordered_Quantity]
				OR ISNULL(tgt.[Available_On_Order_Quantity],'') <> src.[Available_On_Order_Quantity] 
				OR ISNULL(tgt.[Available_Total_Available_Quantity],'') <> src.[Available_Total_Available_Quantity]
				OR ISNULL(tgt.[Available_Average_Cost],'') <> src.[Available_Average_Cost]
				OR ISNULL(tgt.[Returns_On_Hand_Quantity],'') <> src.[Returns_On_Hand_Quantity]
				OR ISNULL(tgt.[Returns_Reserved_On_Hand_Quantity],'') <> src.[Returns_Reserved_On_Hand_Quantity] 
				OR ISNULL(tgt.[Returns_Available_On_Hand_Quantity],'') <> src.[Returns_Available_On_Hand_Quantity]
				OR ISNULL(tgt.[Returns_Ordered_Quantiity],'') <> src.[Returns_Ordered_Quantiity]
				OR ISNULL(tgt.[Returns_Reserved_Ordered_Quantity],'') <> src.[Returns_Reserved_Ordered_Quantity]
				OR ISNULL(tgt.[Returns_Available_Ordered_Quantity],'') <> src.[Returns_Available_Ordered_Quantity]
				OR ISNULL(tgt.[Returns_On_Order_Quantity],'') <> src.[Returns_On_Order_Quantity] 
				OR ISNULL(tgt.[Returns_Total_Available_Quantity],'') <> src.[Returns_Total_Available_Quantity] 
				OR ISNULL(tgt.[Returns_Average_Cost],'') <> src.[Returns_Average_Cost] 
				OR ISNULL(tgt.[Damaged_On_Hand_Quantity],'') <> src.[Damaged_On_Hand_Quantity] 
				OR ISNULL(tgt.[Damaged_Reserved_On_Hand_Quantity],'') <> src.[Damaged_Reserved_On_Hand_Quantity] 
				OR ISNULL(tgt.[Damaged_Available_On_Hand_Quantity],'') <> src.[Damaged_Available_On_Hand_Quantity] 
				OR ISNULL(tgt.[Damaged_Ordered_Quantiity],'') <> src.[Damaged_Ordered_Quantiity] 
				OR ISNULL(tgt.[Damaged_Reserved_Ordered_Quantity],'') <> src.[Damaged_Reserved_Ordered_Quantity]
				OR ISNULL(tgt.[Damaged_Available_Ordered_Quantity],'') <> src.[Damaged_Available_Ordered_Quantity]
				OR ISNULL(tgt.[Damaged_On_Order_Quantity],'') <> src.[Damaged_On_Order_Quantity] 
				OR ISNULL(tgt.[Damaged_Total_Available_Quantity],'') <> src.[Damaged_Total_Available_Quantity]
				OR ISNULL(tgt.[Damaged_Average_Cost],'') <> src.[Damaged_Average_Cost]
				OR ISNULL(tgt.[Damaged_But_Available_On_Hand_Quantity],'') <> src.[Damaged_But_Available_On_Hand_Quantity]
				OR ISNULL(tgt.[Damaged_But_Available_Reserved_On_Hand_Quantity],'') <> src.[Damaged_But_Available_Reserved_On_Hand_Quantity]
				OR ISNULL(tgt.[Damaged_But_Available_Available_On_Hand_Quantity],'') <> src.[Damaged_But_Available_Available_On_Hand_Quantity]
				OR ISNULL(tgt.[Damaged_But_Available_Ordered_Quantiity],'') <> src.[Damaged_But_Available_Ordered_Quantiity]
				OR ISNULL(tgt.[Damaged_But_Available_Reserved_Ordered_Quantity],'') <> src.[Damaged_But_Available_Reserved_Ordered_Quantity]
				OR ISNULL(tgt.[Damaged_But_Available_Available_Ordered_Quantity],'') <> src.[Damaged_But_Available_Available_Ordered_Quantity]
				OR ISNULL(tgt.[Damaged_But_Available_On_Order_Quantity],'') <> src.[Damaged_But_Available_On_Order_Quantity]
				OR ISNULL(tgt.[Damaged_But_Available_Total_Available_Quantity],'') <> src.[Damaged_But_Available_Total_Available_Quantity]
				OR ISNULL(tgt.[Damaged_But_Available_Average_Cost],'') <> src.[Damaged_But_Available_Average_Cost]
				OR ISNULL(tgt.[Receipt_Hold_On_Hand_Quantity],'') <> src.[Receipt_Hold_On_Hand_Quantity]
				OR ISNULL(tgt.[Receipt_Hold_Reserved_On_Hand_Quantity],'') <> src.[Receipt_Hold_Reserved_On_Hand_Quantity]
				OR ISNULL(tgt.[Receipt_Hold_Available_On_Hand_Quantity],'') <> src.[Receipt_Hold_Available_On_Hand_Quantity]
				OR ISNULL(tgt.[Receipt_Hold_Ordered_Quantiity],'') <> src.[Receipt_Hold_Ordered_Quantiity]
				OR ISNULL(tgt.[Receipt_Hold_Reserved_Ordered_Quantity],'') <> src.[Receipt_Hold_Reserved_Ordered_Quantity]
				OR ISNULL(tgt.[Receipt_Hold_Available_Ordered_Quantity],'') <> src.[Receipt_Hold_Available_Ordered_Quantity]
				OR ISNULL(tgt.[Receipt_Hold_On_Order_Quantity],'') <> src.[Receipt_Hold_On_Order_Quantity]
				OR ISNULL(tgt.[Receipt_Hold_Total_Available_Quantity],'') <> src.[Receipt_Hold_Total_Available_Quantity]
				OR ISNULL(tgt.[Receipt_Hold_Average_Cost],'') <> src.[Receipt_Hold_Average_Cost]
				OR ISNULL(tgt.[Temporary_On_Hand_Quantity],'') <> src.[Temporary_On_Hand_Quantity]
				OR ISNULL(tgt.[Temporary_Reserved_On_Hand_Quantity],'') <> src.[Temporary_Reserved_On_Hand_Quantity]
				OR ISNULL(tgt.[Temporary_Available_On_Hand_Quantity],'') <> src.[Temporary_Available_On_Hand_Quantity]
				OR ISNULL(tgt.[Temporary_Ordered_Quantiity],'') <> src.[Temporary_Ordered_Quantiity]
				OR ISNULL(tgt.[Temporary_Reserved_Ordered_Quantity],'') <> src.[Temporary_Reserved_Ordered_Quantity]
				OR ISNULL(tgt.[Temporary_Available_Ordered_Quantity],'') <> src.[Temporary_Available_Ordered_Quantity]
				OR ISNULL(tgt.[Temporary_On_Order_Quantity],'') <> src.[Temporary_On_Order_Quantity]
				OR ISNULL(tgt.[Temporary_Total_Available_Quantity],'') <> src.[Temporary_Total_Available_Quantity]
				OR ISNULL(tgt.[Temporary_Average_Cost],'') <> src.[Temporary_Average_Cost]
				OR ISNULL(tgt.[Warehouse_Damage_On_Hand_Quantity],'') <> src.[Warehouse_Damage_On_Hand_Quantity]
				OR ISNULL(tgt.[Warehouse_Damage_Reserved_On_Hand_Quantity],'') <> src.[Warehouse_Damage_Reserved_On_Hand_Quantity]
				OR ISNULL(tgt.[Warehouse_Damage_Available_On_Hand_Quantity],'') <> src.[Warehouse_Damage_Available_On_Hand_Quantity]
				OR ISNULL(tgt.[Warehouse_Damage_Ordered_Quantiity],'') <> src.[Warehouse_Damage_Ordered_Quantiity]
				OR ISNULL(tgt.[Warehouse_Damage_Reserved_Ordered_Quantity],'') <> src.[Warehouse_Damage_Reserved_Ordered_Quantity]
				OR ISNULL(tgt.[Warehouse_Damage_Available_Ordered_Quantity],'') <> src.[Warehouse_Damage_Available_Ordered_Quantity]
				OR ISNULL(tgt.[Warehouse_Damage_On_Order_Quantity],'') <> src.[Warehouse_Damage_On_Order_Quantity]
				OR ISNULL(tgt.[Warehouse_Damage_Total_Available_Quantity],'') <> src.[Warehouse_Damage_Total_Available_Quantity]
				OR ISNULL(tgt.[Warehouse_Damage_Average_Cost],'') <> src.[Warehouse_Damage_Average_Cost]
				OR ISNULL(tgt.[Blocking_On_Hand_Quantity],'') <> src.[Blocking_On_Hand_Quantity]
				OR ISNULL(tgt.[Blocking_Reserved_On_Hand_Quantity],'') <> src.[Blocking_Reserved_On_Hand_Quantity]
				OR ISNULL(tgt.[Blocking_Available_On_Hand_Quantity],'') <> src.[Blocking_Available_On_Hand_Quantity]
				OR ISNULL(tgt.[Blocking_Ordered_Quantiity],'') <> src.[Blocking_Ordered_Quantiity]
				OR ISNULL(tgt.[Blocking_Reserved_Ordered_Quantity],'') <> src.[Blocking_Reserved_Ordered_Quantity]
				OR ISNULL(tgt.[Blocking_Available_Ordered_Quantity],'') <> src.[Blocking_Available_Ordered_Quantity]
				OR ISNULL(tgt.[Blocking_On_Order_Quantity],'') <> src.[Blocking_On_Order_Quantity]
				OR ISNULL(tgt.[Blocking_Total_Available_Quantity],'') <> src.[Blocking_Total_Available_Quantity]
				OR ISNULL(tgt.[Blocking_Average_Cost],'') <> src.[Blocking_Average_Cost]
				OR ISNULL(tgt.[General_Quarantine_On_Hand_Quantity],'') <> src.[General_Quarantine_On_Hand_Quantity]
				OR ISNULL(tgt.[General_Quarantine_Reserved_On_Hand_Quantity],'') <> src.[General_Quarantine_Reserved_On_Hand_Quantity] 
				OR ISNULL(tgt.[General_Quarantine_Available_On_Hand_Quantity],'') <> src.[General_Quarantine_Available_On_Hand_Quantity]
				OR ISNULL(tgt.[General_Quarantine_Ordered_Quantiity],'') <> src.[General_Quarantine_Ordered_Quantiity]
				OR ISNULL(tgt.[General_Quarantine_Reserved_Ordered_Quantity],'') <> src.[General_Quarantine_Reserved_Ordered_Quantity]
				OR ISNULL(tgt.[General_Quarantine_Available_Ordered_Quantity],'') <> src.[General_Quarantine_Available_Ordered_Quantity]
				OR ISNULL(tgt.[General_Quarantine_On_Order_Quantity],'') <> src.[General_Quarantine_On_Order_Quantity]
				OR ISNULL(tgt.[General_Quarantine_Total_Available_Quantity],'') <> src.[General_Quarantine_Total_Available_Quantity]
				OR ISNULL(tgt.[General_Quarantine_Average_Cost],'') <> src.[General_Quarantine_Average_Cost]
				OR ISNULL(tgt.[is_Removed_From_Source],'') <> src.[is_Removed_From_Source] 
				OR ISNULL(tgt.[Available_WMS_On_Hand_Quantity],'') <> src.[Available_WMS_On_Hand_Quantity]
				OR ISNULL(tgt.[Returns_WMS_On_Hand_Quantity],'') <> src.[Returns_WMS_On_Hand_Quantity]
				OR ISNULL(tgt.[Damaged_WMS_On_Hand_Quantity],'') <> src.[Damaged_WMS_On_Hand_Quantity]
				OR ISNULL(tgt.[Damaged_But_Available_WMS_On_Hand_Quantity],'') <> src.[Damaged_But_Available_WMS_On_Hand_Quantity]
				OR ISNULL(tgt.[Receipt_Hold_Available_WMS_On_Hand_Quantity],'') <> src.[Receipt_Hold_Available_WMS_On_Hand_Quantity]
				OR ISNULL(tgt.[Temporary_WMS_On_Hand_Quantity],'') <> src.[Temporary_WMS_On_Hand_Quantity]
				OR ISNULL(tgt.[Warehouse_Damage_WMS_On_Hand_Quantity],'') <> src.[Warehouse_Damage_WMS_On_Hand_Quantity]
				OR ISNULL(tgt.[Blocking_WMS_On_Hand_Quantity],'') <> src.[Blocking_WMS_On_Hand_Quantity]
				OR ISNULL(tgt.[General_Quarantine_WMS_On_Hand_Quantity],'') <> src.[General_Quarantine_WMS_On_Hand_Quantity]
		THEN UPDATE SET
				 [Available_On_Hand_Quantity] = src.[Available_On_Hand_Quantity]
				,[Available_Reserved_On_Hand_Quantity] = src.[Available_Reserved_On_Hand_Quantity] 
				,[Available_Available_On_Hand_Quantity] = src.[Available_Available_On_Hand_Quantity] 
				,[Available_Ordered_Quantiity] = src.[Available_Ordered_Quantiity]
				,[Available_Reserved_Ordered_Quantity] = src.[Available_Reserved_Ordered_Quantity]
				,[Available_Available_Ordered_Quantity] = src.[Available_Available_Ordered_Quantity]
				,[Available_On_Order_Quantity] = src.[Available_On_Order_Quantity] 
				,[Available_Total_Available_Quantity] = src.[Available_Total_Available_Quantity]
				,[Available_Average_Cost] = src.[Available_Average_Cost]
				,[Returns_On_Hand_Quantity] = src.[Returns_On_Hand_Quantity]
				,[Returns_Reserved_On_Hand_Quantity] = src.[Returns_Reserved_On_Hand_Quantity] 
				,[Returns_Available_On_Hand_Quantity] = src.[Returns_Available_On_Hand_Quantity]
				,[Returns_Ordered_Quantiity] = src.[Returns_Ordered_Quantiity]
				,[Returns_Reserved_Ordered_Quantity] = src.[Returns_Reserved_Ordered_Quantity]
				,[Returns_Available_Ordered_Quantity] = src.[Returns_Available_Ordered_Quantity]
				,[Returns_On_Order_Quantity] = src.[Returns_On_Order_Quantity] 
				,[Returns_Total_Available_Quantity] = src.[Returns_Total_Available_Quantity] 
				,[Returns_Average_Cost] = src.[Returns_Average_Cost] 
				,[Damaged_On_Hand_Quantity] = src.[Damaged_On_Hand_Quantity] 
				,[Damaged_Reserved_On_Hand_Quantity] = src.[Damaged_Reserved_On_Hand_Quantity] 
				,[Damaged_Available_On_Hand_Quantity] = src.[Damaged_Available_On_Hand_Quantity] 
				,[Damaged_Ordered_Quantiity] = src.[Damaged_Ordered_Quantiity] 
				,[Damaged_Reserved_Ordered_Quantity] = src.[Damaged_Reserved_Ordered_Quantity]
				,[Damaged_Available_Ordered_Quantity] = src.[Damaged_Available_Ordered_Quantity]
				,[Damaged_On_Order_Quantity] = src.[Damaged_On_Order_Quantity] 
				,[Damaged_Total_Available_Quantity] = src.[Damaged_Total_Available_Quantity]
				,[Damaged_Average_Cost] = src.[Damaged_Average_Cost]
				,[Damaged_But_Available_On_Hand_Quantity] = src.[Damaged_But_Available_On_Hand_Quantity]
				,[Damaged_But_Available_Reserved_On_Hand_Quantity] = src.[Damaged_But_Available_Reserved_On_Hand_Quantity]
				,[Damaged_But_Available_Available_On_Hand_Quantity] = src.[Damaged_But_Available_Available_On_Hand_Quantity]
				,[Damaged_But_Available_Ordered_Quantiity] = src.[Damaged_But_Available_Ordered_Quantiity]
				,[Damaged_But_Available_Reserved_Ordered_Quantity] = src.[Damaged_But_Available_Reserved_Ordered_Quantity]
				,[Damaged_But_Available_Available_Ordered_Quantity] = src.[Damaged_But_Available_Available_Ordered_Quantity]
				,[Damaged_But_Available_On_Order_Quantity] = src.[Damaged_But_Available_On_Order_Quantity]
				,[Damaged_But_Available_Total_Available_Quantity] = src.[Damaged_But_Available_Total_Available_Quantity]
				,[Damaged_But_Available_Average_Cost] = src.[Damaged_But_Available_Average_Cost]
				,[Receipt_Hold_On_Hand_Quantity] = src.[Receipt_Hold_On_Hand_Quantity]
				,[Receipt_Hold_Reserved_On_Hand_Quantity] = src.[Receipt_Hold_Reserved_On_Hand_Quantity]
				,[Receipt_Hold_Available_On_Hand_Quantity] = src.[Receipt_Hold_Available_On_Hand_Quantity]
				,[Receipt_Hold_Ordered_Quantiity] = src.[Receipt_Hold_Ordered_Quantiity]
				,[Receipt_Hold_Reserved_Ordered_Quantity] = src.[Receipt_Hold_Reserved_Ordered_Quantity]
				,[Receipt_Hold_Available_Ordered_Quantity] = src.[Receipt_Hold_Available_Ordered_Quantity]
				,[Receipt_Hold_On_Order_Quantity] = src.[Receipt_Hold_On_Order_Quantity]
				,[Receipt_Hold_Total_Available_Quantity] = src.[Receipt_Hold_Total_Available_Quantity]
				,[Receipt_Hold_Average_Cost] = src.[Receipt_Hold_Average_Cost]
				,[Temporary_On_Hand_Quantity] = src.[Temporary_On_Hand_Quantity]
				,[Temporary_Reserved_On_Hand_Quantity] = src.[Temporary_Reserved_On_Hand_Quantity]
				,[Temporary_Available_On_Hand_Quantity] = src.[Temporary_Available_On_Hand_Quantity]
				,[Temporary_Ordered_Quantiity] = src.[Temporary_Ordered_Quantiity]
				,[Temporary_Reserved_Ordered_Quantity] = src.[Temporary_Reserved_Ordered_Quantity]
				,[Temporary_Available_Ordered_Quantity] = src.[Temporary_Available_Ordered_Quantity]
				,[Temporary_On_Order_Quantity] = src.[Temporary_On_Order_Quantity]
				,[Temporary_Total_Available_Quantity] = src.[Temporary_Total_Available_Quantity]
				,[Temporary_Average_Cost] = src.[Temporary_Average_Cost]
				,[Warehouse_Damage_On_Hand_Quantity] = src.[Warehouse_Damage_On_Hand_Quantity]
				,[Warehouse_Damage_Reserved_On_Hand_Quantity] = src.[Warehouse_Damage_Reserved_On_Hand_Quantity]
				,[Warehouse_Damage_Available_On_Hand_Quantity] = src.[Warehouse_Damage_Available_On_Hand_Quantity]
				,[Warehouse_Damage_Ordered_Quantiity] = src.[Warehouse_Damage_Ordered_Quantiity]
				,[Warehouse_Damage_Reserved_Ordered_Quantity] = src.[Warehouse_Damage_Reserved_Ordered_Quantity]
				,[Warehouse_Damage_Available_Ordered_Quantity] = src.[Warehouse_Damage_Available_Ordered_Quantity]
				,[Warehouse_Damage_On_Order_Quantity] = src.[Warehouse_Damage_On_Order_Quantity]
				,[Warehouse_Damage_Total_Available_Quantity] = src.[Warehouse_Damage_Total_Available_Quantity]
				,[Warehouse_Damage_Average_Cost] = src.[Warehouse_Damage_Average_Cost]
				,[Blocking_On_Hand_Quantity] = src.[Blocking_On_Hand_Quantity]
				,[Blocking_Reserved_On_Hand_Quantity] = src.[Blocking_Reserved_On_Hand_Quantity]
				,[Blocking_Available_On_Hand_Quantity] = src.[Blocking_Available_On_Hand_Quantity]
				,[Blocking_Ordered_Quantiity] = src.[Blocking_Ordered_Quantiity]
				,[Blocking_Reserved_Ordered_Quantity] = src.[Blocking_Reserved_Ordered_Quantity]
				,[Blocking_Available_Ordered_Quantity] = src.[Blocking_Available_Ordered_Quantity]
				,[Blocking_On_Order_Quantity] = src.[Blocking_On_Order_Quantity]
				,[Blocking_Total_Available_Quantity] = src.[Blocking_Total_Available_Quantity]
				,[Blocking_Average_Cost] = src.[Blocking_Average_Cost]
				,[General_Quarantine_On_Hand_Quantity] = src.[General_Quarantine_On_Hand_Quantity]
				,[General_Quarantine_Reserved_On_Hand_Quantity] = src.[General_Quarantine_Reserved_On_Hand_Quantity] 
				,[General_Quarantine_Available_On_Hand_Quantity] = src.[General_Quarantine_Available_On_Hand_Quantity]
				,[General_Quarantine_Ordered_Quantiity] = src.[General_Quarantine_Ordered_Quantiity]
				,[General_Quarantine_Reserved_Ordered_Quantity] = src.[General_Quarantine_Reserved_Ordered_Quantity]
				,[General_Quarantine_Available_Ordered_Quantity] = src.[General_Quarantine_Available_Ordered_Quantity]
				,[General_Quarantine_On_Order_Quantity] = src.[General_Quarantine_On_Order_Quantity]
				,[General_Quarantine_Total_Available_Quantity] = src.[General_Quarantine_Total_Available_Quantity]
				,[General_Quarantine_Average_Cost] = src.[General_Quarantine_Average_Cost]
				,[is_Removed_From_Source] = src.[is_Removed_From_Source] 
				,[ETL_Modified_Date] = src.[ETL_Modified_Date]
				,[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1)
				,[Available_WMS_On_Hand_Quantity] = src.[Available_WMS_On_Hand_Quantity]
				,[Returns_WMS_On_Hand_Quantity] = src.[Returns_WMS_On_Hand_Quantity]
				,[Damaged_WMS_On_Hand_Quantity] = src.[Damaged_WMS_On_Hand_Quantity]
				,[Damaged_But_Available_WMS_On_Hand_Quantity] = src.[Damaged_But_Available_WMS_On_Hand_Quantity]
				,[Receipt_Hold_Available_WMS_On_Hand_Quantity] = src.[Receipt_Hold_Available_WMS_On_Hand_Quantity]
				,[Temporary_WMS_On_Hand_Quantity] = src.[Temporary_WMS_On_Hand_Quantity]
				,[Warehouse_Damage_WMS_On_Hand_Quantity] = src.[Warehouse_Damage_WMS_On_Hand_Quantity]
				,[Blocking_WMS_On_Hand_Quantity] = src.[Blocking_WMS_On_Hand_Quantity]
				,[General_Quarantine_WMS_On_Hand_Quantity] = src.[General_Quarantine_WMS_On_Hand_Quantity]
		  WHEN NOT MATCHED BY SOURCE THEN UPDATE SET
			   tgt.[is_Removed_From_Source] = 1
			  ,tgt.[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			  ,tgt.[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1);

			  UPDATE [CWC_DW].[Dimension].[Dates]
			  SET [is_Current_Inventory_Date] = CASE WHEN Date_Key = @Snapshot_Date THEN 1 ELSE 0 END;

END TRY

BEGIN CATCH

	DECLARE @InputParameters NVARCHAR(MAX)
	If @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT @InputParameters = '';
	EXEC Administration.usp_ErrorLogger_Insert @InputParameters;

END CATCH