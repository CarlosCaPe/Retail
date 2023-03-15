
CREATE PROC [Import].[usp_Dimension_Product_Average_Unit_Retail_Update]
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY
	DECLARE @procedureUpdateKey_ AS INT = 0
		,@USER AS VARCHAR(20) = current_user
		,@date AS SMALLDATETIME = getdate()
		,@stored_procedure_name VARCHAR(50) = OBJECT_NAME(@@PROCID);

	EXEC Administration.usp_Procedure_Updates_Insert @procedureName = @stored_procedure_name
		,@procedureUpdateKey = @procedureUpdateKey_ OUTPUT;

	WITH AUR
	AS (
		SELECT [Product_Key] = s.Sales_Line_Product_Key
			,[Average_Unit_Retail_Price] = CASE 
				WHEN SUM([Sales_Line_Ordered_Quantity]) = 0
					THEN NULL
				ELSE SUM(ISNULL(s.[Sales_Line_Price], p.[Trade_Agreement_Price])) / SUM([Sales_Line_Ordered_Quantity])
				END
		FROM [CWC_DW].[Fact].[Sales] s
		INNER JOIN [CWC_DW].[Dimension].[Products] p ON s.Sales_Line_Product_Key = p.Product_Key
		INNER JOIN [CWC_DW].[Dimension].[Dates] d ON d.Calendar_Date = CAST(Sales_Line_Created_Date_EST AS DATE)
		INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes] soa ON s.[Sales_Order_Attribute_Key] = soa.[Sales_Order_Attribute_Key]
		WHERE soa.[Order_Classification] = 'Sale'
			AND s.is_Removed_From_Source = 0
		GROUP BY s.Sales_Line_Product_Key
		)
	UPDATE p
	SET p.[Average_Unit_Retail] = aur.[Average_Unit_Retail_Price]
	FROM [CWC_DW].[Dimension].[Products] p
	LEFT JOIN AUR ON p.Product_Key = aur.Product_Key
	WHERE ISNULL(p.[Average_Unit_Retail], 0) <> ISNULL(aur.[Average_Unit_Retail_Price], 0);

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

