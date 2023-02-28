


CREATE PROC [Import].[usp_Dimension_Product_is_Currently_Backordered_Update]

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	WITH Backordered_Products AS
		(
			SELECT
				 [Product_Key] = b.Sales_Line_Product_Key
			FROM [CWC_DW].[Fact].[Backorders]   b
				INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates]   sd ON b.[Snapshot_Date_Key] = sd.[Date_Key]
				INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates]   bd ON CAST(b.[Sales_Line_Created_Date] AS DATE) = bd.[Calendar_Date]
				INNER JOIN [CWC_DW].[Dimension].[Products]   p ON b.Sales_Line_Product_Key = p.Product_Key
				LEFT JOIN [CWC_DW].[Fact].[Purchase_Orders]   po ON p.Earliest_Open_Purchase_Order_Key = po.Purchase_Order_Key
			WHERE sd.Current_Backorder_Date = 'Current Backorder Date'
			--AND Item_ID = '11729'
			--AND b.is_Removed_From_Source = 0 AND p.Item_ID = '14628' AND Color_Name = 'Currant' AND Size_Name = 'XL'
			GROUP BY b.Sales_Line_Product_Key
		)

	UPDATE p
		SET p.is_Currently_Backordered = CASE WHEN bp.[Product_Key] IS NULL THEN 0 ELSE 1 END
	FROM [CWC_DW].[Dimension].[Products]   p
		LEFT JOIN Backordered_Products bp ON bp.[Product_Key] = p.Product_Key
	WHERE p.is_Currently_Backordered <> CASE WHEN bp.[Product_Key] IS NULL THEN 0 ELSE 1 END;

END TRY

BEGIN CATCH

	DECLARE @InputParameters NVARCHAR(MAX)
	If @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT @InputParameters = '';
	EXEC Administration.usp_ErrorLogger_Insert @InputParameters;

END CATCH
	 
