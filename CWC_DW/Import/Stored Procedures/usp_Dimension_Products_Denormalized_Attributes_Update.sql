

CREATE PROC [Import].[usp_Dimension_Products_Denormalized_Attributes_Update]

AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY


	WITH Item_Name_Standard AS
		(
			SELECT Item_ID,Item_Name_Standard = MAX(Item_Name)
			FROM [CWC_DW].[Dimension].[Products]   p
			GROUP BY Item_ID
		)
	UPDATE p
	SET Item_Name_Standard = ins.Item_Name_Standard
	FROM [CWC_DW].[Dimension].[Products] p
		INNER JOIN Item_Name_Standard ins ON p.Item_ID = ins.Item_ID
	WHERE ISNULL(ins.Item_Name_Standard,'') <> ISNULL(p.Item_Name_Standard,'');

END TRY

BEGIN CATCH

	DECLARE @InputParameters NVARCHAR(MAX)
	If @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT @InputParameters = '';
	EXEC Administration.usp_ErrorLogger_Insert @InputParameters;

END CATCH