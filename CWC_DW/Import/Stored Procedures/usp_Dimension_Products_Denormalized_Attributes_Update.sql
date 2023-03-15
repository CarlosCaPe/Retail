
CREATE PROC [Import].[usp_Dimension_Products_Denormalized_Attributes_Update]
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY
	DECLARE @procedureUpdateKey_ AS INT = 0
		,@USER AS VARCHAR(20) = current_user
		,@date AS SMALLDATETIME = getdate()
		,@stored_procedure_name VARCHAR(50) = OBJECT_NAME(@@PROCID);

	EXEC Administration.usp_Procedure_Updates_Insert @procedureName = @stored_procedure_name
		,@procedureUpdateKey = @procedureUpdateKey_ OUTPUT;

	WITH Item_Name_Standard
	AS (
		SELECT Item_ID
			,Item_Name_Standard = MAX(Item_Name)
		FROM [CWC_DW].[Dimension].[Products] p
		GROUP BY Item_ID
		)
	UPDATE p
	SET Item_Name_Standard = ins.Item_Name_Standard
	FROM [CWC_DW].[Dimension].[Products] p
	INNER JOIN Item_Name_Standard ins ON p.Item_ID = ins.Item_ID
	WHERE ISNULL(ins.Item_Name_Standard, '') <> ISNULL(p.Item_Name_Standard, '');

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