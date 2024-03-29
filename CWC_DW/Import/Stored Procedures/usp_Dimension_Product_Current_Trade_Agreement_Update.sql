﻿
CREATE PROC [Import].[usp_Dimension_Product_Current_Trade_Agreement_Update]
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY
	DECLARE @procedureUpdateKey_ AS INT = 0
		,@USER AS VARCHAR(20) = current_user
		,@date AS SMALLDATETIME = getdate()
		,@stored_procedure_name VARCHAR(50) = OBJECT_NAME(@@PROCID);

	EXEC Administration.usp_Procedure_Updates_Insert @procedureName = @stored_procedure_name
		,@procedureUpdateKey = @procedureUpdateKey_ OUTPUT;

	WITH Trade_Agreement_Cost_Seq
	AS (
		SELECT Item_ID = itemrelation
			,Color_ID = INVENTCOLORID
			,Size_ID = inventsizeid
			,[Price_Disc_Rec_ID] = PriceDiscRecID
			,Cost = Amount
			,[Start_Date] = CAST(FromDate AS DATE)
			,[End_Date] = CAST(ToDate AS DATE)
			,Seq = ROW_NUMBER() OVER (
				PARTITION BY itemrelation
				,INVENTCOLORID
				,inventsizeid
				,CAST(FromDate AS DATE) ORDER BY Amount DESC
					,PriceDiscRecID DESC
				)
			,Seq_Start_Date = ROW_NUMBER() OVER (
				PARTITION BY itemrelation
				,INVENTCOLORID
				,inventsizeid ORDER BY CAST(FromDate AS DATE)
					,PriceDiscRecID
				)
			,Seq_End_Date = DENSE_RANK() OVER (
				PARTITION BY itemrelation
				,INVENTCOLORID
				,inventsizeid ORDER BY CAST(FromDate AS DATE) DESC
				)
		FROM [AX_PRODUCTION].[dbo].ITSTradeAgreementStaging ta
		WHERE MODULE = 2 --1 is Cost and 2 is Price
		)
		,Current_Cost
	AS (
		SELECT Item_ID
			,Color_ID
			,Size_ID
			,[Cost]
			,[Start_Date] = CASE 
				WHEN Seq_Start_Date = 1
					THEN '1/1/1900'
				ELSE [Start_Date]
				END
			,[End_Date] = CASE 
				WHEN Seq_End_Date = 1
					THEN '12/31/9999'
				ELSE CAST(DATEADD(DAY, - 1, LEAD([Start_Date], 1) OVER (
								PARTITION BY Item_ID
								,Color_ID
								,Size_ID ORDER BY [Start_Date]
								)) AS DATE)
				END
		FROM Trade_Agreement_Cost_Seq ta
		WHERE Seq = 1
		)
		,Trade_Agreement_Price_Seq
	AS (
		SELECT Item_ID = itemrelation
			,Color_ID = INVENTCOLORID
			,Size_ID = inventsizeid
			--,Product_Key
			,[Price_Disc_Rec_ID] = PriceDiscRecID
			,Retail_Price = Amount
			,[Start_Date] = CAST(FromDate AS DATE)
			,[End_Date] = CAST(ToDate AS DATE)
			,Seq = ROW_NUMBER() OVER (
				PARTITION BY itemrelation
				,INVENTCOLORID
				,inventsizeid
				,CAST(FromDate AS DATE) ORDER BY Amount DESC
					,PriceDiscRecID DESC
				)
			,Seq_Start_Date = ROW_NUMBER() OVER (
				PARTITION BY itemrelation
				,INVENTCOLORID
				,inventsizeid ORDER BY CAST(FromDate AS DATE)
					,PriceDiscRecID
				)
			,Seq_End_Date = DENSE_RANK() OVER (
				PARTITION BY itemrelation
				,INVENTCOLORID
				,inventsizeid ORDER BY CAST(FromDate AS DATE) DESC
				)
		FROM [AX_PRODUCTION].[dbo].ITSTradeAgreementStaging ta
		WHERE MODULE = 1 --1 is Cost and 2 is Price
		)
		,Current_Price
	AS (
		SELECT Item_ID
			,Color_ID
			,Size_ID
			,Retail_Price
			,[Start_Date] = CASE 
				WHEN Seq_Start_Date = 1
					THEN '1/1/1900'
				ELSE [Start_Date]
				END
			,[End_Date] = CASE 
				WHEN Seq_End_Date = 1
					THEN '12/31/9999'
				ELSE CAST(DATEADD(DAY, - 1, LEAD([Start_Date], 1) OVER (
								PARTITION BY Item_ID
								,Color_ID
								,Size_ID ORDER BY [Start_Date]
								)) AS DATE)
				END
		FROM Trade_Agreement_Price_Seq ta
		WHERE Seq = 1
		)
	UPDATE p
	SET Trade_Agreement_Cost = cc.Cost
		,Trade_Agreement_Price = crp.Retail_Price
	FROM CWC_DW.Dimension.Products p
	LEFT JOIN Current_Cost cc ON p.Item_ID = cc.Item_ID
		AND p.Color_ID = cc.Color_ID
		AND p.Size_ID = cc.Size_ID
		AND CAST(GETDATE() AS DATE) BETWEEN cc.[Start_Date]
			AND cc.[End_Date]
	LEFT JOIN Current_Price crp ON p.Item_ID = crp.Item_ID
		AND p.Color_ID = crp.Color_ID
		AND p.Size_ID = crp.Size_ID
		AND CAST(GETDATE() AS DATE) BETWEEN crp.[Start_Date]
			AND crp.[End_Date]
	WHERE ISNULL(p.Trade_Agreement_Cost, 0) <> ISNULL(cc.Cost, 0)
		OR ISNULL(p.Trade_Agreement_Price, 0) <> ISNULL(crp.Retail_Price, 0);

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
