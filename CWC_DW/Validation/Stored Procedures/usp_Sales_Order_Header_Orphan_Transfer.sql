

CREATE PROC [Validation].[usp_Sales_Order_Header_Orphan_Transfer]

AS


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

BEGIN TRY

		INSERT INTO [AX_PRODUCTION].[dbo].[ITSSalesOrderHeaderEntityStaging_ERRORs]

		--Archive Error Records
		SELECT Error_Transfer_Date = CAST(SYSUTCDATETIME() AS DATETIME2(5)), Error_Reason = 'Orphan - No Sales Order Lines',s.*
		FROM [AX_PRODUCTION].[dbo].[ITSSalesOrderHeaderEntityStaging] s  
		LEFT JOIN [AX_PRODUCTION].[dbo].[ITSSalesOrderLineStaging] sl   ON s.[SALESORDERNUMBER] = sl.[SALESORDERNUMBER]
		WHERE sl.[SALESORDERNUMBER] IS NULL;

		--Delete Error Records 
		DELETE s
		FROM [AX_PRODUCTION].[dbo].[ITSSalesOrderHeaderEntityStaging] s  
		LEFT JOIN [AX_PRODUCTION].[dbo].[ITSSalesOrderLineStaging] sl   ON s.[SALESORDERNUMBER] = sl.[SALESORDERNUMBER]
		WHERE sl.[SALESORDERNUMBER] IS NULL;

END TRY

BEGIN CATCH

	DECLARE @InputParameters NVARCHAR(MAX)
	If @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT @InputParameters = '';
	EXEC Administration.usp_ErrorLogger_Insert @InputParameters;

END CATCH  

