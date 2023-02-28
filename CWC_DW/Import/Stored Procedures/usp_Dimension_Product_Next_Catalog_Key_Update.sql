
CREATE PROC [Import].[usp_Dimension_Product_Next_Catalog_Key_Update]

AS


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY


	--Next Catalog
	WITH Catalogs AS
		(
			SELECT
				[Catalog_Product_Key]
				,cp.[Catalog_Key]
				,cp.[Product_Key]
				,Seq = ROW_NUMBER() OVER(PARTITION BY cp.Product_Key ORDER BY c.Catalog_Drop_Date )
			FROM [CWC_DW].[Fact].[Catalog_Products] cp
			INNER JOIN [CWC_DW].[Dimension].[Catalogs] c ON cp.Catalog_Key = c.Catalog_Key
			WHERE Catalog_Drop_Date > CAST(SYSDATETIME() AS DATE)
		)
	,Next_Catalog AS
		(
			SELECT
				 Catalog_Key
				,Product_Key
			FROM Catalogs
			WHERE Seq = 1
		)

	UPDATE p
	SET p.Next_Catalog_Key = nc.Catalog_Key
	FROM [CWC_DW].[Dimension].[Products] p
	LEFT JOIN Next_Catalog nc ON nc.Product_Key = p.Product_Key
	WHERE ISNULL(p.Next_Catalog_Key,0) <> ISNULL(nc.Catalog_Key,0);
END TRY

BEGIN CATCH

	DECLARE @InputParameters NVARCHAR(MAX)
	If @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT @InputParameters = '';
	EXEC Administration.usp_ErrorLogger_Insert @InputParameters;

END CATCH
