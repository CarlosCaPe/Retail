
CREATE PROC [Import].[usp_Dimension_Product_Weighted_Average_Unit_Cost_Update]
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY
	DECLARE @procedureUpdateKey_ AS INT = 0
		,@USER AS VARCHAR(20) = current_user
		,@date AS SMALLDATETIME = getdate()
		,@stored_procedure_name VARCHAR(50) = OBJECT_NAME(@@PROCID);

	EXEC Administration.usp_Procedure_Updates_Insert @procedureName = @stored_procedure_name
		,@procedureUpdateKey = @procedureUpdateKey_ OUTPUT;

	WITH PO_Product_Total
	AS (
		SELECT po.[Product_Key]
			,[Total_Ordered_Quantity] = SUM([Purchase_Line_Ordered_Quantity])
		FROM [CWC_DW].[Fact].[Purchase_Orders] po
		WHERE ISNULL([Purchase_Line_Ordered_Quantity], 0) > 0
		GROUP BY PO.Product_Key
		)
		,PO_Weight
	AS (
		SELECT po.[Purchase_Order_Key]
			,po.[Product_Key]
			,[Purchase_Line_Purchase_Price]
			,[Commission_Charge_Amount] = ([Commission_Charge_Percentage] / (100)) * ([Purchase_Line_Purchase_Price])
			,[Tariff_Charge_Amount] = ([Tariff_Charge_Percentage] / (100)) * ([Purchase_Line_Purchase_Price])
			,[Duty_Charge_Amount] = ([Duty_Charge_Percentage] / (100)) * ([Purchase_Line_Purchase_Price])
			,[Freight_Charge_Amount] = ([Freight_Charge_Percentage] / (100)) * ([Purchase_Line_Purchase_Price])
			,[Freight_In_Charge_Amount] = ([Freight_In_Charge_Percentage] / (100)) * ([Purchase_Line_Purchase_Price])
			,Cost_Unit_Total = [Purchase_Line_Purchase_Price] + ([Commission_Charge_Percentage] / (100)) * ([Purchase_Line_Purchase_Price]) + ([Tariff_Charge_Percentage] / (100)) * ([Purchase_Line_Purchase_Price]) + ([Duty_Charge_Percentage] / (100)) * ([Purchase_Line_Purchase_Price]) + ([Freight_Charge_Percentage] / (100)) * ([Purchase_Line_Purchase_Price]) + ([Freight_In_Charge_Percentage] / (100)) * ([Purchase_Line_Purchase_Price])
			,[Purchase_Line_Ordered_Quantity]
			,[PO_Weight] = po.Purchase_Line_Ordered_Quantity / CAST(popt.[Total_Ordered_Quantity] AS NUMERIC(18, 6))
		FROM [CWC_DW].[Fact].[Purchase_Orders] po
		INNER JOIN PO_Product_Total popt ON po.Product_Key = popt.Product_Key
		) --SELECT * FROM PO_Weight
		,Calc_Final
	AS (
		SELECT [Product_Key]
			,[Weighted_PO_AUC] = SUM(Cost_Unit_Total * PO_Weight)
		FROM PO_Weight
		--WHERE Product_Key = 149986
		GROUP BY [Product_Key]
		)
	UPDATE p
	SET p.PO_Weighted_Average_Unit_Cost = [Weighted_PO_AUC]
	FROM [Dimension].[Products] p
	LEFT JOIN Calc_Final cf ON p.Product_Key = cf.Product_Key
	WHERE ISNULL(p.PO_Weighted_Average_Unit_Cost, 0) <> ISNULL([Weighted_PO_AUC], 0);

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