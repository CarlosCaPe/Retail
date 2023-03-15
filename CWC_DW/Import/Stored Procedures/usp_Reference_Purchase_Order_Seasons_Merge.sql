
CREATE PROC [Import].[usp_Reference_Purchase_Order_Seasons_Merge]
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

BEGIN TRY
	DECLARE @procedureUpdateKey_ AS INT = 0
		,@USER AS VARCHAR(20) = current_user
		,@date AS SMALLDATETIME = getdate()
		,@stored_procedure_name VARCHAR(50) = OBJECT_NAME(@@PROCID);

	EXEC Administration.usp_Procedure_Updates_Insert @procedureName = @stored_procedure_name
		,@procedureUpdateKey = @procedureUpdateKey_ OUTPUT;

	WITH src
	AS (
		SELECT [Purchase_Order_Header_Season_CD] = CAST(NULLIF(REASONCODE, '') AS VARCHAR(10))
			,[Purchase_Order_Header_Season] = MAX(CAST(NULLIF(REASONCOMMENT, '') AS VARCHAR(25)))
		FROM [AX_PRODUCTION].[dbo].[PurchPurchaseOrderHeaderV2Staging] p
		INNER JOIN [AX_PRODUCTION].[dbo].[PurchPurchaseOrderLineV2Staging] pl ON p.PURCHASEORDERNUMBER = pl.PURCHASEORDERNUMBER
		WHERE CAST(NULLIF(REASONCODE, '') AS VARCHAR(10)) IS NOT NULL
		GROUP BY CAST(NULLIF(REASONCODE, '') AS VARCHAR(10))
		)
		,tgt
	AS (
		SELECT *
		FROM [Reference].[Purchace_Order_Seasons]
		)
	MERGE INTO tgt
	USING src
		ON tgt.[Purchase_Order_Header_Season_CD] = src.[Purchase_Order_Header_Season_CD]
	WHEN NOT MATCHED
		THEN
			INSERT (
				[Purchase_Order_Header_Season_CD]
				,[Purchase_Order_Header_Season]
				)
			VALUES (
				src.[Purchase_Order_Header_Season_CD]
				,src.[Purchase_Order_Header_Season]
				)
	WHEN MATCHED
		AND ISNULL(tgt.[Purchase_Order_Header_Season], '') <> ISNULL(src.[Purchase_Order_Header_Season], '')
		THEN
			UPDATE
			SET [Purchase_Order_Header_Season] = src.[Purchase_Order_Header_Season];

	UPDATE pop
	SET Purchase_Order_Header_Season = pos.Purchase_Order_Header_Season
	FROM [CWC_DW].[Dimension].[Purchase_Order_Properties] pop
	INNER JOIN [CWC_DW].[Reference].[Purchace_Order_Seasons] pos ON pop.Purchase_Order_Header_Season_CD = pos.Purchase_Order_Header_Season_CD
	WHERE ISNULL(pop.[Purchase_Order_Header_Season], '') <> ISNULL(pos.Purchase_Order_Header_Season, '');

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