
CREATE PROC [Import].[usp_Dimension_Product_Next_Catalog_Key_Update]
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY
	DECLARE @procedureUpdateKey_ AS INT = 0
		,@USER AS VARCHAR(20) = current_user
		,@date AS SMALLDATETIME = getdate()
		,@stored_procedure_name VARCHAR(50) = OBJECT_NAME(@@PROCID);

	EXEC Administration.usp_Procedure_Updates_Insert @procedureName = @stored_procedure_name
		,@procedureUpdateKey = @procedureUpdateKey_ OUTPUT;

	--Next Catalog
	WITH Catalogs
	AS (
		SELECT [Catalog_Product_Key]
			,cp.[Catalog_Key]
			,cp.[Product_Key]
			,Seq = ROW_NUMBER() OVER (
				PARTITION BY cp.Product_Key ORDER BY c.Catalog_Drop_Date
				)
		FROM [CWC_DW].[Fact].[Catalog_Products] cp
		INNER JOIN [CWC_DW].[Dimension].[Catalogs] c ON cp.Catalog_Key = c.Catalog_Key
		WHERE Catalog_Drop_Date > CAST(SYSDATETIME() AS DATE)
		)
		,Next_Catalog
	AS (
		SELECT Catalog_Key
			,Product_Key
		FROM Catalogs
		WHERE Seq = 1
		)
	UPDATE p
	SET p.Next_Catalog_Key = nc.Catalog_Key
	FROM [CWC_DW].[Dimension].[Products] p
	LEFT JOIN Next_Catalog nc ON nc.Product_Key = p.Product_Key
	WHERE ISNULL(p.Next_Catalog_Key, 0) <> ISNULL(nc.Catalog_Key, 0);

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
