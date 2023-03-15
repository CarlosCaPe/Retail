
CREATE PROC [Validation].[usp_Sales_Order_Line_Orphan_Transfer]
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

BEGIN TRY
	DECLARE @procedureUpdateKey_ AS INT = 0
		,@USER AS VARCHAR(20) = current_user
		,@date AS SMALLDATETIME = getdate()
		,@stored_procedure_name VARCHAR(50) = OBJECT_NAME(@@PROCID);

	EXEC Administration.usp_Procedure_Updates_Insert @procedureName = @stored_procedure_name
		,@procedureUpdateKey = @procedureUpdateKey_ OUTPUT;

	INSERT INTO [AX_PRODUCTION].[dbo].[ITSSalesOrderLineStaging_Errors]
	--Archive Error Records
	SELECT Error_Transfer_Date = CAST(SYSUTCDATETIME() AS DATETIME2(5))
		,Error_Reason = 'Orphan - No Sales Order Header'
		,sl.*
	--INTO [AX_PRODUCTION].[dbo].[ITSSalesOrderLineStaging_Errors]
	FROM [AX_PRODUCTION].[dbo].[ITSSalesOrderHeaderEntityStaging] s
	RIGHT JOIN [AX_PRODUCTION].[dbo].[ITSSalesOrderLineStaging] sl ON s.[SALESORDERNUMBER] = sl.[SALESORDERNUMBER]
	WHERE s.[SALESORDERNUMBER] IS NULL;

	--Delete Error Records 
	DELETE sl
	FROM [AX_PRODUCTION].[dbo].[ITSSalesOrderHeaderEntityStaging] s
	RIGHT JOIN [AX_PRODUCTION].[dbo].[ITSSalesOrderLineStaging] sl ON s.[SALESORDERNUMBER] = sl.[SALESORDERNUMBER]
	WHERE s.[SALESORDERNUMBER] IS NULL;

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
