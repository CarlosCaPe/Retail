

CREATE PROC [Validation].[usp_Sales_Order_Line_Orphan_Transfer]

AS


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

BEGIN TRY

	INSERT INTO [AX_PRODUCTION].[dbo].[ITSSalesOrderLineStaging_Errors]

	--Archive Error Records
	SELECT Error_Transfer_Date = CAST(SYSUTCDATETIME() AS DATETIME2(5)), Error_Reason = 'Orphan - No Sales Order Header',sl.*
	--INTO [AX_PRODUCTION].[dbo].[ITSSalesOrderLineStaging_Errors]
	FROM [AX_PRODUCTION].[dbo].[ITSSalesOrderHeaderEntityStaging] s  
		RIGHT JOIN [AX_PRODUCTION].[dbo].[ITSSalesOrderLineStaging] sl   ON s.[SALESORDERNUMBER] = sl.[SALESORDERNUMBER]
	WHERE s.[SALESORDERNUMBER] IS NULL;

	--Delete Error Records 
	DELETE sl
	FROM [AX_PRODUCTION].[dbo].[ITSSalesOrderHeaderEntityStaging] s  
		RIGHT JOIN [AX_PRODUCTION].[dbo].[ITSSalesOrderLineStaging] sl   ON s.[SALESORDERNUMBER] = sl.[SALESORDERNUMBER]
	WHERE s.[SALESORDERNUMBER] IS NULL;

END TRY

BEGIN CATCH

	DECLARE @InputParameters NVARCHAR(MAX)
	If @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT @InputParameters = '';
	EXEC Administration.usp_ErrorLogger_Insert @InputParameters;

END CATCH  
