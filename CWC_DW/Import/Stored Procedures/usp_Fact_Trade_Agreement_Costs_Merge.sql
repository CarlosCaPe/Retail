



CREATE PROC [Import].[usp_Fact_Trade_Agreement_Costs_Merge]

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

BEGIN TRY


	WITH Trade_Agreement_Seq AS
		(
			SELECT 
				 Item_Number = itemrelation
				,Color_ID = INVENTCOLORID
				,Size_ID = inventsizeid
				,Product_Key
				,[Price_Disc_Rec_ID] = PriceDiscRecID
				,Cost = Amount
				,[Start_Date] = CAST(FromDate AS DATE)
				,[End_Date] = CAST(ToDate AS DATE)
				,Seq = ROW_NUMBER() OVER(PARTITION BY itemrelation,INVENTCOLORID,inventsizeid,CAST(FromDate AS DATE) ORDER BY Amount DESC, PriceDiscRecID DESC)
				,Seq_Start_Date = ROW_NUMBER() OVER(PARTITION BY itemrelation,INVENTCOLORID,inventsizeid ORDER BY CAST(FromDate AS DATE),PriceDiscRecID)
				,Seq_End_Date = DENSE_RANK() OVER(PARTITION BY itemrelation,INVENTCOLORID,inventsizeid ORDER BY CAST(FromDate AS DATE) DESC)
			FROM [AX_PRODUCTION].[dbo].ITSTradeAgreementStaging   ta
				 INNER JOIN [CWC_DW].[Dimension].[Products]   p ON ta.itemrelation = ISNULL(p.Item_ID,'') AND ta.INVENTCOLORID = ISNULL(p.Color_ID,'') AND ta.INVENTSIZEID = ISNULL(p.Size_ID,'')
			WHERE MODULE = 2 --1 is Price and 2 is Cost

		)
	,src AS
		(
			SELECT 
				 [Product_Key]
				,[Price_Disc_Rec_ID]
				,[Cost]
				,[Start_Date] = CASE WHEN Seq_Start_Date = 1 THEN '1/1/1900' ELSE [Start_Date] END
				,[End_Date] = CASE WHEN Seq_End_Date = 1 THEN '12/31/9999' ELSE CAST(DATEADD(DAY,-1,LEAD([Start_Date],1) OVER (PARTITION BY Product_Key ORDER BY [Start_Date])) AS DATE) END 
				--,Seq_Start_Date
				,[is_Removed_From_Source] = CAST(0 AS BIT)
				,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
				,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
				,[ETL_Modified_Count] = CAST(1 AS TINYINT)
			FROM Trade_Agreement_Seq ta
			WHERE Seq = 1
		)
	,tgt AS (SELECT * FROM [CWC_DW].[Fact].[Trade_Agreement_Costs]  )

	MERGE INTO tgt USING src
		ON src.[Price_Disc_Rec_ID] = tgt.[Price_Disc_Rec_ID]
			WHEN NOT MATCHED THEN
				INSERT([Product_Key],[Price_Disc_Rec_ID],[Cost],[Start_Date],[End_Date],[is_Removed_From_Source],[ETL_Created_Date],[ETL_Modified_Date],[ETL_Modified_Count])
				VALUES(src.[Product_Key],src.[Price_Disc_Rec_ID],src.[Cost],src.[Start_Date],src.[End_Date],src.[is_Removed_From_Source],src.[ETL_Created_Date],src.[ETL_Modified_Date],src.[ETL_Modified_Count])
			WHEN MATCHED AND 
				  ISNULL(tgt.[Product_Key],'') <> ISNULL(src.[Product_Key],'')
			   OR ISNULL(tgt.[Cost],'') <> ISNULL(src.[Cost],'')
			   OR ISNULL(tgt.[Start_Date],'') <> ISNULL(src.[Start_Date],'')
			   OR ISNULL(tgt.[End_Date],'') <> ISNULL(src.[End_Date],'')
			   OR ISNULL(tgt.[is_Removed_From_Source],'') <> ISNULL(src.[is_Removed_From_Source],'')
			THEN UPDATE SET
			   [Product_Key] = src.[Product_Key]
			  ,[Cost] = src.[Cost]
			  ,[Start_Date] = src. [Start_Date]
			  ,[End_Date] = src.[End_Date]
			  ,[is_Removed_From_Source] = src.[is_Removed_From_Source]
			  ,[ETL_Modified_Date] = src.[ETL_Modified_Date]
			  ,[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1)
			WHEN NOT MATCHED BY SOURCE AND tgt.[is_Removed_From_Source] <> 1 THEN UPDATE SET
				 tgt.[is_Removed_From_Source] = 1
				,tgt.[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
				,tgt.[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1);


END TRY

BEGIN CATCH

	DECLARE @InputParameters NVARCHAR(MAX)
	If @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT @InputParameters = '';
	EXEC Administration.usp_ErrorLogger_Insert @InputParameters;

END CATCH
