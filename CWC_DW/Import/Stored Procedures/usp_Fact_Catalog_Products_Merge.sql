

CREATE PROC [Import].[usp_Fact_Catalog_Products_Merge]

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

BEGIN TRY

	WITH src AS
	(
	SELECT
		 c.[Catalog_Key]
		,p.[Product_Key]
		,[is_Removed_From_Source] = CAST(0 AS BIT)
		,[is_Excluded] = CAST(0 AS BIT)
		,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
		,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
		,[ETL_Modified_Count] = CAST(1 AS TINYINT)
	FROM [AX_PRODUCTION].[dbo].[RetailCatalogProductStaging]   cp
	INNER JOIN [CWC_DW].[Dimension].[Products]   p ON p.[Product_Varient_Number] = cp.[DISPLAYPRODUCTNUMBER]
	INNER JOIN [CWC_DW].[Dimension].[Catalogs]   c ON c.Catalog_Number = cp.CATALOGNUMBER
	)
	,tgt AS (SELECT * FROM [CWC_DW].[Fact].[Catalog_Products]  )

	MERGE INTO tgt USING src
		ON tgt.[Catalog_Key] = src.[Catalog_Key] AND tgt.[Product_Key] = src.[Product_Key]
			WHEN NOT MATCHED THEN
				INSERT([Catalog_Key],[Product_Key],[is_Removed_From_Source],[is_Excluded],[ETL_Created_Date],[ETL_Modified_Date],[ETL_Modified_Count])
				VALUES(src.[Catalog_Key],src.[Product_Key],src.[is_Removed_From_Source],src.[is_Excluded],src.[ETL_Created_Date],src.[ETL_Modified_Date],src.[ETL_Modified_Count])
			WHEN MATCHED AND
				ISNULL(tgt.[is_Removed_From_Source],'') <> ISNULL(src.[is_Removed_From_Source],'')
			THEN UPDATE SET
			   [is_Removed_From_Source] = src.[is_Removed_From_Source] 
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
