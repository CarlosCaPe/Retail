CREATE PROC [Import].[usp_Reference_Purchase_Order_Seasons_Merge]

  AS

WITH src AS
(
SELECT
 [Purchase_Order_Header_Season_CD] = CAST(NULLIF(REASONCODE,'') AS VARCHAR(10))
,[Purchase_Order_Header_Season] = MAX(CAST(NULLIF(REASONCOMMENT,'') AS VARCHAR(25)))
--INTO Reference.Purchace_Order_Seasons
FROM [AX_PRODUCTION].[dbo].[PurchPurchaseOrderHeaderV2Staging] (NOLOCK) p
INNER JOIN [AX_PRODUCTION].[dbo].[PurchPurchaseOrderLineV2Staging] (NOLOCK) pl ON p.PURCHASEORDERNUMBER = pl.PURCHASEORDERNUMBER
WHERE CAST(NULLIF(REASONCODE,'') AS VARCHAR(10)) IS NOT NULL
GROUP BY CAST(NULLIF(REASONCODE,'') AS VARCHAR(10))
)
,tgt AS (SELECT * FROM [Reference].[Purchace_Order_Seasons])

MERGE INTO tgt USING src
	ON tgt.[Purchase_Order_Header_Season_CD] = src.[Purchase_Order_Header_Season_CD]
		WHEN NOT MATCHED THEN
			INSERT([Purchase_Order_Header_Season_CD],[Purchase_Order_Header_Season])
			VALUES(src.[Purchase_Order_Header_Season_CD],src.[Purchase_Order_Header_Season])
		WHEN MATCHED AND
			ISNULL(tgt.[Purchase_Order_Header_Season],'') <> ISNULL(src.[Purchase_Order_Header_Season],'')
		THEN UPDATE SET
			[Purchase_Order_Header_Season] = src.[Purchase_Order_Header_Season];


UPDATE pop
SET Purchase_Order_Header_Season = pos.Purchase_Order_Header_Season
FROM [CWC_DW].[Dimension].[Purchase_Order_Properties] (NOLOCK) pop
INNER JOIN [CWC_DW].[Reference].[Purchace_Order_Seasons] (NOLOCK) pos ON pop.Purchase_Order_Header_Season_CD = pos.Purchase_Order_Header_Season_CD
WHERE ISNULL(pop.[Purchase_Order_Header_Season],'') <> ISNULL(pos.Purchase_Order_Header_Season,'');