
CREATE PROC [Import].[usp_Dimension_Product_First_Vendor_Packing_Slip_Key_Update]
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY
	DECLARE @procedureUpdateKey_ AS INT = 0
		,@USER AS VARCHAR(20) = current_user
		,@date AS SMALLDATETIME = getdate()
		,@stored_procedure_name VARCHAR(50) = OBJECT_NAME(@@PROCID);

	EXEC Administration.usp_Procedure_Updates_Insert @procedureName = @stored_procedure_name
		,@procedureUpdateKey = @procedureUpdateKey_ OUTPUT;

	WITH Vendor_Packing_Slips
	AS (
		SELECT [Vendor_Packing_Slip_Key]
			,[Product_Key]
			,Seq = ROW_NUMBER() OVER (
				PARTITION BY Product_Key ORDER BY [Vendor_Packing_Accounting_Date]
					,[Invent_Trans_ID]
					,[Vendor_Packing_Slip_ID]
				)
		FROM [CWC_DW].[Fact].[Vendor_Packing_Slips]
		)
		,First_Vendor_Packing_Slip
	AS (
		SELECT [Vendor_Packing_Slip_Key]
			,[Product_Key]
		FROM Vendor_Packing_Slips
		WHERE Seq = 1
		)
	--SELECT *
	UPDATE p
	SET First_Vendor_Packing_Slip_Key = vps.Vendor_Packing_Slip_Key
	FROM [CWC_DW].[Dimension].[Products] p
	LEFT JOIN First_Vendor_Packing_Slip vps ON vps.Product_Key = p.Product_Key
	WHERE ISNULL(First_Vendor_Packing_Slip_Key, 0) <> ISNULL(vps.Vendor_Packing_Slip_Key, 0);

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
