
CREATE PROC [Import].[usp_Fact_Vendor_Packing_Slip_is_Backordered_Product_Update]
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

	WITH Backorder_Products
	AS (
		SELECT DISTINCT [Snapshot_Date_Key]
			,[Sales_Line_Product_Key]
			,[is_Current_Backorder] = 1
		FROM [CWC_DW].[Fact].[Backorders]
		)
	UPDATE vps
	SET is_Backordered_Product = ISNULL(bp.is_Current_Backorder, 0)
	FROM [CWC_DW].[Fact].[Vendor_Packing_Slips] vps
	INNER JOIN [CWC_DW].[Dimension].[Dates] d ON vps.Vendor_Packing_Accounting_Date = d.Calendar_Date
	LEFT JOIN Backorder_Products bp ON vps.[Product_Key] = bp.[Sales_Line_Product_Key]
		AND d.Date_Key = bp.[Snapshot_Date_Key]
	WHERE ISNULL(is_Backordered_Product, 0) <> ISNULL(bp.is_Current_Backorder, 0);

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

