


CREATE PROC [Import].[usp_Dimension_Product_Earliest_Open_Purchase_Order_Key_Update]

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	WITH PO_Product_Sequence AS
	(
	SELECT
		   [Purchase_Order_Key]
		  ,Purchase_Order_Number
		  ,Purchase_Order_Line_Number
		  ,[Product_Key]
		  ,[Seq] = ROW_NUMBER() OVER(PARTITION BY [Product_Key] ORDER BY [Purchase_Line_Confirmed_Delivery_Date],[Purchase_Order_Number])
	FROM [CWC_DW].[Fact].[Purchase_Orders]   po
		INNER JOIN [CWC_DW].[Dimension].[Purchase_Order_Properties]   pop ON po.Purchase_Order_Property_Key = pop.Purchase_Order_Property_Key
		INNER JOIN [CWC_DW].[Dimension].[Purchase_Order_Fill]   pof ON po.Purchase_Order_Fill_Key = pof.Purchase_Order_Fill_Key
	WHERE		    po.Purchase_Order_Header_Accounting_Date >= '8/15/2020' 
				AND po.Purchase_Line_Confirmed_Delivery_Date >= CAST(GETDATE() -1 AS DATE) --Reactivated 01/17/2022
				AND pop.Purchase_Order_Header_Status IN ('Open','Received')
				AND pop.Purchase_Order_Line_Status IN ('Open','Received')
				AND pof.Purchase_Order_Fill_Status = 'Active'
				AND pof.Purchase_Order_Line_Fill_Status = 'Active' --Added 08/19/2021
				AND po.is_Removed_From_Source = 0
	) --SELECT * FROM PO_Product_Sequence WHERE Purchase_Order_Number = '19242'
	,First_Open_PO AS
	(
		SELECT
			 [Purchase_Order_Key]
			,[Product_Key]
		FROM PO_Product_Sequence
		WHERE Seq = 1
	)
	UPDATE p
	SET p.Earliest_Open_Purchase_Order_Key = CASE WHEN po.Purchase_Order_Key IS NULL THEN NULL ELSE po.Purchase_Order_Key END
	FROM [CWC_DW].[Dimension].[Products]   p
	LEFT JOIN First_Open_PO po ON p.Product_Key = po.Product_Key
	WHERE ISNULL(p.Earliest_Open_Purchase_Order_Key,'') <> ISNULL(po.Purchase_Order_Key,'');

END TRY

BEGIN CATCH

	DECLARE @InputParameters NVARCHAR(MAX)
	If @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT @InputParameters = '';
	EXEC Administration.usp_ErrorLogger_Insert @InputParameters;

END CATCH
