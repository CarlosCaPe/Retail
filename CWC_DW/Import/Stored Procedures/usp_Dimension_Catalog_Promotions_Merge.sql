

CREATE PROC [Import].[usp_Dimension_Catalog_Promotions_Merge] AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

;WITH Catalogs AS
	(
		SELECT [Catalog_Key]
			  ,[Catalog_Number]
			  ,[Catalog_Name]
			  ,[Catalog_Description] = ISNULL([Catalog_Description],[Catalog_Name])
			  ,[Catalog_Drop_Date]
			  ,[is_Removed_From_Source]
			  ,[is_Excluded]
			  ,[ETL_Created_Date]
			  ,[ETL_Modified_Date]
			  ,[ETL_Modified_Count]
		  FROM [CWC_DW].[Dimension].[Catalogs]
	)
,src AS
	(
		SELECT
			 [Catalog_Key]
			,[Source_CD] = NULLIF([SOURCEID],'')
			,[Coupon_CD] = NULLIF([ITSCOUPONID],'')
			,[Catalog_Number]
			,[Catalog_Name]
			,[Catalog_Description]
			,[Catalog_Drop_Date]
			,[Promotion_Message] = NULLIF([ITSPROMOTIONMESSAGE],'')
			,[is_Removed_From_Source] = CAST(0 AS BIT)
			,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Count] = CAST(1 AS SMALLINT)
		--INTO [CWC_DW].[Dimension].[Catalog_Promotions]
		FROM [AX_PRODUCTION].[dbo].[MCRSourceCodeStaging] sc
		LEFT JOIN Catalogs c ON c.Catalog_Number = sc.CATALOGNUMBER
	)
,tgt AS (SELECT * FROM [CWC_DW].[Dimension].[Catalog_Promotions])

MERGE INTO tgt USING src
	ON tgt.[Source_CD] = src.[Source_CD]
		WHEN NOT MATCHED THEN
			INSERT([Catalog_Key],[Source_CD],[Coupon_CD],[Catalog_Number],[Catalog_Name],[Catalog_Description],[Catalog_Drop_Date],[Promotion_Message],[is_Removed_From_Source]
				  ,[ETL_Created_Date],[ETL_Modified_Date],[ETL_Modified_Count])
			VALUES(src.[Catalog_Key],src.[Source_CD],src.[Coupon_CD],src.[Catalog_Number],src.[Catalog_Name],src.[Catalog_Description],src.[Catalog_Drop_Date],src.[Promotion_Message],src.[is_Removed_From_Source]
				  ,src.[ETL_Created_Date],src.[ETL_Modified_Date],src.[ETL_Modified_Count])
		WHEN MATCHED AND
				   ISNULL(tgt.[Catalog_Key],'') <> ISNULL(src.[Catalog_Key],'')
				OR ISNULL(tgt.[Source_CD],'') <> ISNULL(src.[Source_CD],'')
				OR ISNULL(tgt.[Coupon_CD],'') <> ISNULL(src.[Coupon_CD],'')
				OR ISNULL(tgt.[Catalog_Number],'') <> ISNULL(src.[Catalog_Number],'')
				OR ISNULL(tgt.[Catalog_Name],'') <> ISNULL(src.[Catalog_Name],'')
				OR ISNULL(tgt.[Catalog_Description],'') <> ISNULL(src.[Catalog_Description],'')
				OR ISNULL(tgt.[Catalog_Drop_Date],'') <> ISNULL(src.[Catalog_Drop_Date],'')
				OR ISNULL(tgt.[Promotion_Message],'') <> ISNULL(src.[Promotion_Message],'')
				OR ISNULL(tgt.[is_Removed_From_Source],'') <> ISNULL(src.[is_Removed_From_Source],'')
				--OR ISNULL(tgt.[ETL_Created_Date],'') <> ISNULL(src.[ETL_Created_Date],'')
				--OR ISNULL(tgt.[ETL_Modified_Date],'') <> ISNULL(src.[ETL_Modified_Date],'')
				--OR ISNULL(tgt.[ETL_Modified_Count],'') <> ISNULL(src.[ETL_Modified_Count],'')
		THEN UPDATE SET
				 [Catalog_Key] = src.[Catalog_Key]
				,[Source_CD] = src.[Source_CD]
				,[Coupon_CD] = src.[Coupon_CD]
				,[Catalog_Number] = src.[Catalog_Number]
				,[Catalog_Name] = src.[Catalog_Name]
				,[Catalog_Description] = src.[Catalog_Description]
				,[Catalog_Drop_Date] = src.[Catalog_Drop_Date]
				,[Promotion_Message] = src.[Promotion_Message]
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
				