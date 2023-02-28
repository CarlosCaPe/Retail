

CREATE PROC [Import].[usp_Dimension_Product_First_Catalog_Key_Update]

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY


	--First Catalog
	WITH Catalogs AS
		(
			SELECT
				[Catalog_Product_Key]
				,cp.[Catalog_Key]
				,cp.[Product_Key]
				,Seq = ROW_NUMBER() OVER(PARTITION BY cp.Product_Key ORDER BY c.Catalog_Drop_Date)
			FROM [CWC_DW].[Fact].[Catalog_Products] cp
			INNER JOIN [CWC_DW].[Dimension].[Catalogs] c ON cp.Catalog_Key = c.Catalog_Key
			WHERE Catalog_Drop_Date <= CAST(SYSDATETIME() AS DATE)
		)
	,First_Catalog AS
		(
			SELECT
				 Catalog_Key
				,Product_Key
			FROM Catalogs
			WHERE Seq = 1
		)

	UPDATE p
	SET p.First_Catalog_Key = fc.Catalog_Key
	FROM [CWC_DW].[Dimension].[Products] p
	LEFT JOIN First_Catalog fc ON fc.Product_Key = p.Product_Key
	WHERE ISNULL(p.First_Catalog_Key,0) <> ISNULL(fc.Catalog_Key,0) ;
END TRY

BEGIN CATCH

	DECLARE @InputParameters NVARCHAR(MAX)
	If @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT @InputParameters = '';
	EXEC Administration.usp_ErrorLogger_Insert @InputParameters;

END CATCH