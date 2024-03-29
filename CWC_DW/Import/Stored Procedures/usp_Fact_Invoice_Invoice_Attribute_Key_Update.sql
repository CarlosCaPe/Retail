﻿
CREATE PROC [Import].[usp_Fact_Invoice_Invoice_Attribute_Key_Update]
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

	WITH Snapshot_Products
	AS (
		SELECT DISTINCT Sales_Key
			,Product_Key = Sales_Line_Product_Key
		FROM [CWC_DW].[Fact].[Backorders] b
		)
		,Backorder_Invoices
	AS (
		SELECT i.Invoice_Key
			,is_Backorder_Fill = CASE 
				WHEN sp.Sales_Key IS NOT NULL
					THEN 1
				ELSE 0
				END
		FROM [CWC_DW].[Fact].[Invoices] i
		INNER JOIN Snapshot_Products sp ON i.Sales_Key = sp.Sales_Key
			AND i.Invoice_Line_Product_Key = sp.Product_Key
			AND LEFT(Invoice_Number, 3) = 'INV'
		)
		,Free_Shipping
	AS (
		SELECT Invoice_Number
			,is_Free_Shipping = CASE 
				WHEN ISNULL(SUM(i.[Invoice_Header_Total_Charge_Amount]), 0) > 0
					THEN 0
				ELSE 1
				END
		FROM [CWC_DW].[Fact].[Invoices] i
		GROUP BY Invoice_Number
		)
	UPDATE i
	SET i.Invoice_Attribute_Key = ia.Invoice_Attribute_Key
	FROM [CWC_DW].[Fact].[Invoices] i
	LEFT JOIN Backorder_Invoices b ON i.Invoice_Key = b.Invoice_Key
	LEFT JOIN Free_Shipping f ON i.Invoice_Number = f.Invoice_Number
	LEFT JOIN [CWC_DW].[Dimension].[Invoice_Attributes] ia ON ISNULL(b.is_Backorder_Fill, 0) = ia.is_Backorder_Fill
		AND ISNULL((
				CASE 
					WHEN DATEDIFF(DAY, i.Invoice_Line_Date, GETDATE()) > 90
						THEN 1
					ELSE 0
					END
				), 0) = ia.is_Baked
		AND f.is_Free_Shipping = ia.is_Free_Shipping
	WHERE ISNULL(i.Invoice_Attribute_Key, 0) <> ia.Invoice_Attribute_Key;

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
