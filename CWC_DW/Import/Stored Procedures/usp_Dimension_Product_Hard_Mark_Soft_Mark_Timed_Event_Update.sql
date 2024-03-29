﻿
CREATE PROC [Import].[usp_Dimension_Product_Hard_Mark_Soft_Mark_Timed_Event_Update]
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY
	DECLARE @procedureUpdateKey_ AS INT = 0
		,@USER AS VARCHAR(20) = current_user
		,@date AS SMALLDATETIME = getdate()
		,@stored_procedure_name VARCHAR(50) = OBJECT_NAME(@@PROCID);

	EXEC Administration.usp_Procedure_Updates_Insert @procedureName = @stored_procedure_name
		,@procedureUpdateKey = @procedureUpdateKey_ OUTPUT;

	WITH src
	AS (
		SELECT D.*
			,row_number() OVER (
				PARTITION BY D.ITEMID
				,D.COLOR
				,D.SIZE_
				,D.STYLE ORDER BY VALIDDISCOUNT DESC
					,D.OFFERID DESC
				) DISCOUNTROW
			,Offer_Name = Name
		FROM (
			SELECT DL.OFFERID
				,DL.OFFERPRICE
				,DL.ITEMID
				,DL.COLOR
				,DL.SIZE_
				,DL.STYLE
				,D.VALIDTO
				,D.VALIDFROM
				,D.NAME
				,D.PERIODICDISCOUNTTYPE
				,DL.OFFERDISCOUNTPERCENTAGE
				,IIF((
						(
							D.VALIDFROM <= GETDATE()
							AND D.VALIDTO > GETDATE()
							)
						AND (D.STATUS = 1)
						), 1, 0) AS VALIDDISCOUNT
				,CASE 
					WHEN G.PRICEGROUPID NOT IN (
							'CallCenter'
							,'EComm'
							)
						THEN 'Retail'
					ELSE G.PRICEGROUPID
					END AS PRICEGROUPID
			FROM [AX_PRODUCTION].[dbo].[RetailDiscountLineStaging] DL
			LEFT OUTER JOIN [AX_PRODUCTION].[dbo].[RetailDiscountStaging] D ON D.OFFERID = DL.OFFERID
			LEFT OUTER JOIN [AX_PRODUCTION].[dbo].[RetailDiscountPriceGroupStaging] G ON G.OFFERID = DL.OFFERID
			WHERE D.PERIODICDISCOUNTTYPE = 3
				AND PRICEGROUPID <> 'Retail'
			) D
		WHERE D.VALIDDISCOUNT > 0
		)
		,Flags
	AS (
		SELECT p.Product_Key
			,is_Hard_Mark = MAX(CASE 
					WHEN Offer_Name LIKE 'Hard Mark%'
						THEN 1
					ELSE 0
					END)
			,is_Soft_Mark = MAX(CASE 
					WHEN Offer_Name LIKE 'Soft Mark%'
						THEN 1
					ELSE 0
					END)
			,is_Timed_Event = MAX(CASE 
					WHEN Offer_Name LIKE 'Markdowns Catalog%'
						OR Offer_Name LIKE 'Catalog Markdowns%'
						THEN 1
					ELSE 0
					END)
			,Offer_Price_Hard_Mark = MAX(CASE 
					WHEN Offer_Name LIKE 'Hard Mark%'
						THEN OFFERPRICE
					ELSE NULL
					END)
			,Offer_Price_Soft_Mark = MIN(CASE 
					WHEN Offer_Name LIKE 'Soft Mark%'
						THEN OFFERPRICE
					ELSE NULL
					END)
			,Offer_Price_Timed_Event = MIN(CASE 
					WHEN Offer_Name LIKE 'Markdowns Catalog%'
						OR Offer_Name LIKE 'Catalog Markdowns%'
						THEN OFFERPRICE
					ELSE NULL
					END)
			,Price_Count = COUNT(OFFERPRICE)
		FROM [CWC_DW].[Dimension].[Products] p
		LEFT JOIN src ON src.ITEMID = p.Item_ID
			AND src.COLOR = p.Color_ID
			AND src.SIZE_ = p.Size_ID
		GROUP BY Product_Key --,src.OFFERID,src.Offer_Name
		)
	UPDATE p
	SET is_Hard_Mark = f.is_Hard_Mark
		,is_Soft_Mark = f.is_Soft_Mark
		,is_Timed_Event = f.is_Timed_Event
		,[Offer_Price_Hard_Mark] = f.Offer_Price_Hard_Mark
		,[Offer_Price_Soft_Mark] = f.Offer_Price_Soft_Mark
		,[Offer_Price_Timed_Event] = f.Offer_Price_Timed_Event
	FROM [CWC_DW].[Dimension].[Products] p
	LEFT JOIN Flags f ON f.Product_Key = p.Product_Key
	WHERE ISNULL(p.is_Hard_Mark, 0) <> ISNULL(f.is_Hard_Mark, 0)
		OR ISNULL(p.is_Soft_Mark, 0) <> ISNULL(f.is_Soft_Mark, 0)
		OR ISNULL(p.is_Timed_Event, 0) <> ISNULL(f.is_Timed_Event, 0)
		OR ISNULL(p.[Offer_Price_Hard_Mark], 0) <> ISNULL(f.Offer_Price_Hard_Mark, 0)
		OR ISNULL(p.[Offer_Price_Soft_Mark], 0) <> ISNULL(f.Offer_Price_Soft_Mark, 0)
		OR ISNULL(p.[Offer_Price_Timed_Event], 0) <> ISNULL(f.Offer_Price_Timed_Event, 0);

	UPDATE Administration.Procedure_Updates
	SET [Status] = 'SUCCESS'
		,Affected_Rows = @@ROWCOUNT
		,End_Date = getdate()
	WHERE Procedure_Update_Key = @procedureUpdateKey_
END TRY

BEGIN CATCH
	IF @procedureUpdateKey_ <> 0
		UPDATE [Administration].Procedure_Updates
		SET [Status] = 'FAILED'
			,Error = ERROR_MESSAGE()
			,End_Date = getdate()
		WHERE Procedure_Update_Key = @procedureUpdateKey_

	DECLARE @InputParameters NVARCHAR(MAX)

	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SELECT @InputParameters = '';

	EXEC Administration.usp_Error_Logger_Insert @InputParameters;
END CATCH