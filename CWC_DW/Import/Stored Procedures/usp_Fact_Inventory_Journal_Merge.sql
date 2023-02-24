CREATE PROC [Import].[usp_Fact_Inventory_Journal_Merge]

AS

WITH src AS
	(
		SELECT 
			 [Rec_ID] = ij.RECID
			,[Journal_ID] = CAST(JournalID AS VARCHAR(15))
			,[Journal_Date] = CAST(TRANSDATE AS DATE)
			,[Journal_Date_Key] = d.Date_Key
			,[Product_Key] = p.[Product_Key]
			,[Inventory_Journal_Property_Key] = ijp.Inventory_Journal_Property_Key
			,ijt.Inventory_Journal_Type_Key
			,[Inventory_Warehouse_Key] = iw.Inventory_Warehouse_Key
			,[Line_Number] = CAST(LINENUM AS SMALLINT)
			,[Quantity] = CAST(Qty AS INT)
			,[is_Removed_From_Source] = CAST(0 AS BIT)
			,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Count] = CAST(1 AS TINYINT)
			--INTO [CWC_DW].[Fact].[Inventory_Journals]
		FROM [Entity_Staging].[dbo].[rsmWMSInventoryJournalStaging] ij
		INNER JOIN [CWC_DW].[Dimension].[Inventory_Journal_Types] (NOLOCK) ijt ON ij.JournalNameID = ijt.Inventory_Journal_Type_CD
		INNER JOIN [CWC_DW].[Dimension].[Inventory_Journal_Properties] (NOLOCK) ijp ON ij.COUNTINGREASONCODE =ijp.[Counting_Reason_CD] 																				AND ISNULL(ij.INVENTSTATUSID,'') = ISNULL(ijp.[Inventory_Status_CD],'')
		INNER JOIN [CWC_DW].[Dimension].[Products] p ON ISNULL(ij.ItemID,'') = ISNULL(p.Item_ID,'') AND ISNULL(ij.InventColorID,'') = ISNULL(p.Color_ID,'') AND ISNULL(ij.InventSizeID,'') = ISNULL(p.Size_ID,'')
		INNER JOIN [CWC_DW].[Dimension].[Inventory_Warehouses] iw ON iw.Inventory_Warehouse_ID = ij.INVENTLOCATIONID
		INNER JOIN [CWC_DW].[Dimension].[Dates] d ON d.Calendar_Date = ij.TRANSDATE
		--WHERE CAST(TransDate AS DATE) = '11/28/2022'
	)
,tgt AS (SELECT * FROM [CWC_DW].[Fact].[Inventory_Journals] (NOLOCK))

MERGE INTO tgt USING src
	ON tgt.[Rec_ID] = src.[Rec_ID] --tgt.Journal_ID = src.Journal_ID AND tgt.Line_Number = src.Line_Number AND tgt.Product_Key = src.Product_Key
		WHEN NOT MATCHED THEN
			INSERT([Rec_ID],[Journal_ID],[Journal_Date],[Journal_Date_Key],[Product_Key],[Inventory_Journal_Property_Key],[Inventory_Journal_Type_Key],[Inventory_Warehouse_Key],[Line_Number]
				  ,[Quantity],[is_Removed_From_Source],[ETL_Created_Date],[ETL_Modified_Date],[ETL_Modified_Count])
			VALUES(src.[Rec_ID],src.[Journal_ID],src.[Journal_Date],src.[Journal_Date_Key],src.[Product_Key],src.[Inventory_Journal_Property_Key],src.[Inventory_Journal_Type_Key],src.[Inventory_Warehouse_Key],src.[Line_Number]
				  ,src.[Quantity],src.[is_Removed_From_Source],src.[ETL_Created_Date],src.[ETL_Modified_Date],src.[ETL_Modified_Count])
		WHEN MATCHED AND
			   ISNULL(tgt.[Journal_ID],'') <> ISNULL(src.[Journal_ID],'')
			OR ISNULL(tgt.[Journal_Date_Key],'') <> ISNULL(src.[Journal_Date_Key],'')
			OR ISNULL(tgt.[Product_Key],'') <> ISNULL(src.[Product_Key],'')
			OR ISNULL(tgt.[Inventory_Journal_Property_Key],'') <> ISNULL(src.[Inventory_Journal_Property_Key],'')
			OR ISNULL(tgt.[Inventory_Journal_Type_Key],'') <> ISNULL(src.[Inventory_Journal_Type_Key],'')
			OR ISNULL(tgt.[Inventory_Warehouse_Key],'') <> ISNULL(src.[Inventory_Warehouse_Key],'')
			OR ISNULL(tgt.[Line_Number],'') <> ISNULL(src.[Line_Number],'')
			OR ISNULL(tgt.[Quantity],'') <> ISNULL(src.[Quantity],'')
			OR ISNULL(tgt.[is_Removed_From_Source],'') <> ISNULL(src.[is_Removed_From_Source],'')
		THEN UPDATE SET
			 [Journal_ID] = src.[Journal_ID]
			,[Journal_Date] = src.[Journal_Date]
			,[Journal_Date_Key] = src.[Journal_Date_Key]
			,[Product_Key] = src.[Product_Key]
			,[Inventory_Journal_Property_Key] = src.[Inventory_Journal_Property_Key]
			,[Inventory_Journal_Type_Key] = src.[Inventory_Journal_Type_Key]
			,[Inventory_Warehouse_Key] = src.[Inventory_Warehouse_Key]
			,[Line_Number] = src.[Line_Number]
			,[Quantity] = src.[Quantity]
			,[is_Removed_From_Source] = src.[is_Removed_From_Source] 
			,[ETL_Modified_Date] = src.[ETL_Modified_Date]
			,[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1)
		WHEN NOT MATCHED BY SOURCE THEN UPDATE SET
			 tgt.[is_Removed_From_Source] = 1
			,tgt.[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,tgt.[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1);