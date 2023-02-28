

CREATE PROC [Import].[usp_Fact_Purchase_Orders_Received_Quantity_Update]

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

BEGIN TRY

		WITH Vendor_Packing_Slips AS
		(
			SELECT 
				 Purchase_Order_Key,Received_Quantity = SUM(CAST(ISNULL(vps.[Vendor_Packing_Slip_Quantity],0) AS SMALLINT))
				,Vendor_Packing_Slip_Count = COUNT(vps.Vendor_Packing_Slip_Key)
			FROM [CWC_DW].[Fact].[Vendor_Packing_Slips]   vps
			WHERE is_Removed_From_Source = 0
			GROUP BY Purchase_Order_Key
		)
		UPDATE po
		SET 
			Received_Quantity = ISNULL(vps.Received_Quantity,0)
			,Vendor_Packing_Slip_Count = ISNULL(vps.Vendor_Packing_Slip_Count,0)
		FROM [CWC_DW].[Fact].[Purchase_Orders]   po
		  LEFT JOIN [Vendor_Packing_Slips] vps ON po.[Purchase_Order_Key] = vps.[Purchase_Order_Key]
		WHERE ISNULL(po.Received_Quantity,0) <> ISNULL(vps.Received_Quantity,0) OR ISNULL(po.Vendor_Packing_Slip_Count,0) <> ISNULL(vps.Vendor_Packing_Slip_Count,0)
		;
END TRY

BEGIN CATCH

	DECLARE @InputParameters NVARCHAR(MAX)
	If @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT @InputParameters = '';
	EXEC Administration.usp_ErrorLogger_Insert @InputParameters;

END CATCH