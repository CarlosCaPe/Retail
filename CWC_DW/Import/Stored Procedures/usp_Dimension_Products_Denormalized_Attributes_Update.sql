CREATE PROC [Import].[usp_Dimension_Products_Denormalized_Attributes_Update]

AS

WITH Item_Name_Standard AS
	(
		SELECT Item_ID,Item_Name_Standard = MAX(Item_Name)
		FROM [CWC_DW].[Dimension].[Products] (NOLOCK) p
		--WHERE Item_ID = '18623'
		GROUP BY Item_ID
	)
	--SELECT Product_Key,Item_Name_Standard = ins.Item_Name_Standard,*
UPDATE p
SET Item_Name_Standard = ins.Item_Name_Standard
FROM [CWC_DW].[Dimension].[Products] p
	INNER JOIN Item_Name_Standard ins ON p.Item_ID = ins.Item_ID
WHERE ISNULL(ins.Item_Name_Standard,'') <> ISNULL(p.Item_Name_Standard,'');