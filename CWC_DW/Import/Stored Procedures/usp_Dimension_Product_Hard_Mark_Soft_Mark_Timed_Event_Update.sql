CREATE PROC [Import].[usp_Dimension_Product_Hard_Mark_Soft_Mark_Timed_Event_Update] AS

WITH src AS
(
		SELECT D.*, 
			row_number() OVER (PARTITION BY D.ITEMID, D.COLOR, D.SIZE_, D.STYLE ORDER BY VALIDDISCOUNT DESC, D.OFFERID DESC) DISCOUNTROW,Offer_Name = Name
			FROM (
					select DL.OFFERID, DL.OFFERPRICE, DL.ITEMID, DL.COLOR, DL.SIZE_, 
					DL.STYLE, D.VALIDTO, D.VALIDFROM, D.NAME, D.PERIODICDISCOUNTTYPE, DL.OFFERDISCOUNTPERCENTAGE,
					IIF(((D.VALIDFROM <= GETDATE() AND D.VALIDTO > GETDATE())AND (D.STATUS = 1)),1,0) AS VALIDDISCOUNT, 
					CASE WHEN G.PRICEGROUPID NOT IN  ('CallCenter','EComm') THEN 'Retail' ELSE  G.PRICEGROUPID END AS PRICEGROUPID
					from [AX_PRODUCTION].[dbo].[RetailDiscountLineStaging] DL
					left outer join [AX_PRODUCTION].[dbo].[RetailDiscountStaging] D on D.OFFERID = DL.OFFERID
					left outer join [AX_PRODUCTION].[dbo].[RetailDiscountPriceGroupStaging] G ON G.OFFERID = DL.OFFERID
					WHERE D.PERIODICDISCOUNTTYPE = 3 and PRICEGROUPID <> 'Retail'
				) D
				WHERE D.VALIDDISCOUNT > 0
				

) 
--SELECT * FROM src
--INNER JOIN [CWC_DW].[Dimension].[Products] p ON src.ITEMID = p.Item_ID AND src.COLOR = p.Color_ID AND src.SIZE_ = p.Size_ID
--WHERE Product_Key IN (28292)
,Flags AS
(
SELECT 
	 p.Product_Key
	,is_Hard_Mark = MAX(CASE WHEN Offer_Name LIKE 'Hard Mark%' THEN 1 ELSE 0 END)
	,is_Soft_Mark = MAX(CASE WHEN Offer_Name LIKE 'Soft Mark%' THEN 1 ELSE 0 END)
	,is_Timed_Event = MAX(CASE WHEN Offer_Name LIKE 'Markdowns Catalog%' OR Offer_Name LIKE 'Catalog Markdowns%' THEN 1 ELSE 0 END)
	,Offer_Price_Hard_Mark = MAX(CASE WHEN Offer_Name LIKE 'Hard Mark%' THEN OFFERPRICE ELSE NULL END)
	,Offer_Price_Soft_Mark = MIN(CASE WHEN Offer_Name LIKE 'Soft Mark%' THEN OFFERPRICE ELSE NULL END)
	,Offer_Price_Timed_Event = MIN(CASE WHEN Offer_Name LIKE 'Markdowns Catalog%' OR Offer_Name LIKE 'Catalog Markdowns%' THEN OFFERPRICE ELSE NULL END)
	,Price_Count = COUNT(OFFERPRICE)
FROM [CWC_DW].[Dimension].[Products] p
LEFT JOIN src ON src.ITEMID = p.Item_ID AND src.COLOR = p.Color_ID AND src.SIZE_ = p.Size_ID
GROUP BY Product_Key--,src.OFFERID,src.Offer_Name
--ORDER BY COUNT(*),Product_Key
) --SELECT * FROM flags WHERE Product_Key IN (SELECT Product_Key FROM Dimension.Products WHERE Item_ID = '30000')
UPDATE p
SET  is_Hard_Mark = f.is_Hard_Mark
	,is_Soft_Mark = f.is_Soft_Mark
	,is_Timed_Event = f.is_Timed_Event
    ,[Offer_Price_Hard_Mark] = f.Offer_Price_Hard_Mark
	,[Offer_Price_Soft_Mark] = f.Offer_Price_Soft_Mark
	,[Offer_Price_Timed_Event] = f.Offer_Price_Timed_Event
FROM [CWC_DW].[Dimension].[Products] p
LEFT JOIN Flags f ON f.Product_Key = p.Product_Key
WHERE ISNULL(p.is_Hard_Mark,0) <> ISNULL(f.is_Hard_Mark,0)
   OR ISNULL(p.is_Soft_Mark,0) <> ISNULL(f.is_Soft_Mark,0)
   OR ISNULL(p.is_Timed_Event,0) <> ISNULL(f.is_Timed_Event,0)
   OR ISNULL(p.[Offer_Price_Hard_Mark],0) <> ISNULL(f.Offer_Price_Hard_Mark,0)
   OR ISNULL(p.[Offer_Price_Soft_Mark],0) <> ISNULL(f.Offer_Price_Soft_Mark,0)
   OR ISNULL(p.[Offer_Price_Timed_Event],0) <> ISNULL(f.Offer_Price_Timed_Event,0)
   ;