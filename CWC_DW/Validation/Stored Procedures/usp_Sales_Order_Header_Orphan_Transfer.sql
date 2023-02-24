
CREATE PROC [Validation].[usp_Sales_Order_Header_Orphan_Transfer]

AS

BEGIN TRANSACTION

	BEGIN TRY

		INSERT INTO [AX_PRODUCTION].[dbo].[ITSSalesOrderHeaderEntityStaging_ERRORs]

		--Archive Error Records
		SELECT Error_Transfer_Date = CAST(SYSUTCDATETIME() AS DATETIME2(5)), Error_Reason = 'Orphan - No Sales Order Lines',s.*
		--INTO [AX_PRODUCTION].[dbo].[ITSSalesOrderHeaderEntityStaging_ERRORs]
		FROM [AX_PRODUCTION].[dbo].[ITSSalesOrderHeaderEntityStaging] s (NOLOCK)
		LEFT JOIN [AX_PRODUCTION].[dbo].[ITSSalesOrderLineStaging] sl (NOLOCK) ON s.[SALESORDERNUMBER] = sl.[SALESORDERNUMBER]
		WHERE sl.[SALESORDERNUMBER] IS NULL;

		--Delete Error Records 
		DELETE s
		FROM [AX_PRODUCTION].[dbo].[ITSSalesOrderHeaderEntityStaging] s (NOLOCK)
		LEFT JOIN [AX_PRODUCTION].[dbo].[ITSSalesOrderLineStaging] sl (NOLOCK) ON s.[SALESORDERNUMBER] = sl.[SALESORDERNUMBER]
		WHERE sl.[SALESORDERNUMBER] IS NULL;

	END TRY

BEGIN CATCH

    SELECT   
        ERROR_NUMBER() AS ErrorNumber  
        ,ERROR_SEVERITY() AS ErrorSeverity  
        ,ERROR_STATE() AS ErrorState  
        ,ERROR_PROCEDURE() AS ErrorProcedure  
        ,ERROR_LINE() AS ErrorLine  
        ,ERROR_MESSAGE() AS ErrorMessage; 

IF @@TRANCOUNT > 0  
	ROLLBACK TRANSACTION;

END CATCH

IF @@TRANCOUNT > 0  
    COMMIT TRANSACTION;  

