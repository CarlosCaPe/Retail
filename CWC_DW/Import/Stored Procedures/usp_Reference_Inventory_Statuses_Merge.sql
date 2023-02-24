CREATE PROC [Import].[usp_Reference_Inventory_Statuses_Merge]

AS

WITH src AS
(
SELECT
       Inventory_Status_ID = [STATUSID]
      ,Inventory_Status = [STATUSNAME]
      ,is_Will_Block_Inventory = CAST([WILLSTATUSBLOCKINVENTORY] AS BIT)
  FROM [Entity_Staging].[dbo].[WHSInventoryStatusStaging]
)
,tgt AS (SELECT * FROM [CWC_DW].[Reference].[Inventory_Statuses] (NOLOCK))

MERGE INTO tgt USING src
	ON src.Inventory_Status_ID = tgt.Inventory_Status_ID
		WHEN NOT MATCHED THEN
			INSERT(Inventory_Status_ID,Inventory_Status,is_Will_Block_Inventory)
			VALUES(src.Inventory_Status_ID,src.Inventory_Status,src.is_Will_Block_Inventory)
		WHEN MATCHED AND
			 ISNULL(tgt.Inventory_Status,'') <> ISNULL(src.Inventory_Status,'') 
          OR ISNULL(tgt.is_Will_Block_Inventory,'') <> ISNULL(src.is_Will_Block_Inventory,'')
		THEN UPDATE SET
			 Inventory_Status = src.Inventory_Status
		    ,is_Will_Block_Inventory = src.is_Will_Block_Inventory;