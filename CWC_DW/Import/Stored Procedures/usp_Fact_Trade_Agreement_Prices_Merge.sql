
CREATE PROC [Import].[usp_Fact_Trade_Agreement_Prices_Merge]

AS

WITH Trade_Agreement_Seq AS
	(
		SELECT 
			 Item_Number = itemrelation
			,Color_ID = INVENTCOLORID
			,Size_ID = inventsizeid
			,Product_Key
			,Price_Disc_Rec_ID = PriceDiscRecID
			,Price = Amount
			,[Start_Date] = CAST(FromDate AS DATE)
			,[End_Date] = CAST(ToDate AS DATE)
			,Seq = ROW_NUMBER() OVER(PARTITION BY itemrelation,INVENTCOLORID,inventsizeid,CAST(FromDate AS DATE) ORDER BY Amount DESC, PriceDiscRecID DESC)
		FROM [AX_PRODUCTION].[dbo].ITSTradeAgreementStaging (NOLOCK) ta
			 INNER JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON ta.itemrelation = ISNULL(p.Item_ID,'') AND ta.INVENTCOLORID = ISNULL(p.Color_ID,'') AND ta.INVENTSIZEID = ISNULL(p.Size_ID,'')
		WHERE MODULE = 1 --1 is Price and 2 is Cost
			  --AND TODATE = '1/1/1900'
			  --AND p.Product_Key IN (46150)--(61957,61958)
			  --ORDER BY Product_Key, FromDate
			  --AND Product_Key =  96776
	)
	,TA_Count AS
	(
		SELECT 
			Product_Key
		,Price_Disc_Rec_ID
		,[Start_Date]
		,Seq = ROW_NUMBER() OVER(PARTITION BY Product_Key ORDER BY [Start_Date] ASC, [Price_Disc_Rec_ID] DESC)
		,Seq2 = ROW_NUMBER() OVER(PARTITION BY Product_Key ORDER BY [Start_Date] DESC, [Price_Disc_Rec_ID] ASC)
		FROM Trade_Agreement_Seq ta
		WHERE ta.Seq = 1
	) --SELECT * FROM TA_Count WHERE Product_Key = 40646
,src AS
	(
		SELECT 
				ta.[Product_Key]
			,ta.[Price_Disc_Rec_ID]
			,ta.[Price]
			,[Start_Date] = CASE WHEN tac.seq = 1 THEN '1/1/1900' ELSE ta.[Start_Date] END
			,[End_Date] = CASE WHEN tac.seq2 = 1 THEN '12/31/9999' ELSE ISNULL(CAST(DATEADD(DAY,-1,LEAD(ta.[Start_Date],1) OVER (PARTITION BY ta.Product_Key ORDER BY ta.[Start_Date])) AS DATE),'12/31/9999') END
			,[is_Removed_From_Source] = CAST(0 AS BIT)
			,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Count] = CAST(1 AS TINYINT)
		--INTO CWC_DW.Fact.Trade_Agreement_Prices
		FROM Trade_Agreement_Seq ta
		LEFT JOIN TA_Count tac ON ta.Price_Disc_Rec_ID = tac.Price_Disc_Rec_ID
		WHERE ta.Seq = 1
			--AND Product_Key IN (46150)--(61957,61958)
	) --SELECT * FROM src WHERE Product_Key = 96776
,tgt AS (SELECT * FROM [CWC_DW].[Fact].[Trade_Agreement_Prices] (NOLOCK))

MERGE INTO tgt USING src
	ON src.Price_Disc_Rec_ID = tgt.Price_Disc_Rec_ID
		WHEN NOT MATCHED THEN
			INSERT([Product_Key],[Price_Disc_Rec_ID],[Price],[Start_Date],[End_Date],[is_Removed_From_Source],[ETL_Created_Date],[ETL_Modified_Date],[ETL_Modified_Count])
			VALUES(src.[Product_Key],src.[Price_Disc_Rec_ID],src.[Price],src.[Start_Date],src.[End_Date],src.[is_Removed_From_Source],src.[ETL_Created_Date],src.[ETL_Modified_Date],src.[ETL_Modified_Count])
		WHEN MATCHED AND 
		      ISNULL(tgt.[Product_Key],'') <> ISNULL(src.[Product_Key],'')
		   OR ISNULL(tgt.[Price],'') <> ISNULL(src.[Price],'')
		   OR ISNULL(tgt.[Start_Date],'') <> ISNULL(src.[Start_Date],'')
		   OR ISNULL(tgt.[End_Date],'') <> ISNULL(src.[End_Date],'')
		   OR ISNULL(tgt.[is_Removed_From_Source],'') <> ISNULL(src.[is_Removed_From_Source],'')
		THEN UPDATE SET
		   [Product_Key] = src.[Product_Key]
		  ,[Price] = src.[Price]
		  ,[Start_Date] = src. [Start_Date]
		  ,[End_Date] = src.[End_Date]
		  ,[is_Removed_From_Source] = src.[is_Removed_From_Source]
		  ,[ETL_Modified_Date] = src.[ETL_Modified_Date]
		  ,[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1)
		WHEN NOT MATCHED BY SOURCE AND tgt.[is_Removed_From_Source] <> 1 THEN UPDATE SET
			 tgt.[is_Removed_From_Source] = 1
			,tgt.[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,tgt.[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1);
