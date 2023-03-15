
CREATE PROC [Import].[usp_Dimension_Product_Average_Unit_Cost_Update]
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY
	DECLARE @procedureUpdateKey_ AS INT = 0
		,@USER AS VARCHAR(20) = current_user
		,@date AS SMALLDATETIME = getdate()
		,@stored_procedure_name VARCHAR(50) = OBJECT_NAME(@@PROCID);

	EXEC Administration.usp_Procedure_Updates_Insert @procedureName = @stored_procedure_name
		,@procedureUpdateKey = @procedureUpdateKey_ OUTPUT;

	WITH Invoices
	AS (
		SELECT i.[Sales_Key]
			,[Invoice_Number] = MIN(Invoice_Number)
			,[Invoice_Count] = COUNT(i.Invoice_Key)
			,[Invoice_Date] = MIN(i.[Invoice_Line_Date])
			,[Invoice_Amount] = SUM(i.[Invoice_Line_Amount])
			,[Invoice_Quantity] = SUM(i.[Invoice_Line_Quantity])
			,[Invoice_Tax_Amount] = SUM(i.[Invoice_Line_Tax_Amount])
			,[Baked] = SUM(CAST(ia.is_Baked AS TINYINT))
		FROM [CWC_DW].[Fact].[Invoices] i
		INNER JOIN [CWC_DW].[Dimension].[Products] p ON i.[Invoice_Line_Product_Key] = p.[Product_Key]
		INNER JOIN [CWC_DW].[Dimension].[Invoice_Attributes] ia ON i.Invoice_Attribute_Key = ia.Invoice_Attribute_Key
		GROUP BY i.[Sales_Key]
		)
		,AUC_Details
	AS (
		SELECT s.[Sales_Key]
			,slp.Sales_Line_Type
			,slp.Sales_Line_Status
			,soa.Order_Classification
			,[Product_Key] = s.Sales_Line_Product_Key
			,Cost = NULLIF(tc.Cost, 0)
			,[Invoice_Quantity]
			,s.[Sales_Line_Ordered_Quantity]
			,Sales_Line_Cost_Price = NULLIF(s.Sales_Line_Cost_Price, 0)
			,[Shipped_Quantity] = i.[Invoice_Quantity]
			,s.[Sales_Line_Amount]
			,[Total_Sales_Line_Amount] = s.[Sales_Line_Amount]
			,[Total_Sales_Line_Ordered_Quantity] = s.[Sales_Line_Ordered_Quantity]
			,[Return_Units] = CASE 
				WHEN slp.[Sales_Line_Type] = 'Return'
					THEN s.[Sales_Line_Ordered_Quantity]
				ELSE NULL
				END
			,[Return_Landed_Cost] = CASE 
				WHEN slp.Sales_Line_Type = 'Return'
					THEN (s.[Sales_Line_Ordered_Quantity] * ISNULL(NULLIF(s.Sales_Line_Cost_Price, 0), NULLIF(tc.Cost, 0)))
				ELSE NULL
				END
			,[Shipped_Landed_Cost] = ISNULL(NULLIF(s.Sales_Line_Cost_Price, 0), NULLIF(tc.Cost, 0)) * i.[Invoice_Quantity]
		FROM [CWC_DW].[Fact].[Sales] s
		INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] d ON d.Calendar_Date = CAST(s.[Sales_Line_Created_Date_est] AS DATE)
		INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes] soa ON s.[Sales_Order_Attribute_Key] = soa.[Sales_Order_Attribute_Key]
		INNER JOIN [CWC_DW].[Dimension].[Products] p ON s.Sales_Line_Product_Key = p.[Product_Key]
		INNER JOIN [CWC_DW].[Dimension].[Inventory_Warehouses] iw ON s.Shipping_Inventory_Warehouse_Key = iw.Inventory_Warehouse_Key
		INNER JOIN [CWC_DW].[Dimension].[Sales_Line_Properties] slp ON s.Sales_Line_Property_Key = slp.Sales_Line_Property_Key
		LEFT JOIN [CWC_DW].[Dimension].[Sales_Header_Properties] shp ON s.Sales_Header_Property_Key = shp.Sales_Header_Property_Key
		LEFT JOIN [CWC_DW].[Dimension].[Sales_Order_Fill] sof ON s.Sales_Order_Fill_Key = sof.Sales_Order_Fill_Key
		LEFT JOIN [CWC_DW].[Fact].[Trade_Agreement_Costs] tc ON s.Sales_Line_Product_Key = tc.Product_Key
			AND CAST(s.[Sales_Line_Created_Date] AS DATE) BETWEEN tc.[Start_Date]
				AND tc.[End_Date]
			AND tc.is_Removed_From_Source = 0
		LEFT JOIN [CWC_DW].[Fact].[Trade_Agreement_Prices] tp ON s.Sales_Line_Product_Key = tp.Product_Key
			AND CAST(s.[Sales_Line_Created_Date] AS DATE) BETWEEN tp.[Start_Date]
				AND tp.[End_Date]
			AND tp.is_Removed_From_Source = 0
		LEFT JOIN [Invoices] i ON i.Sales_Key = s.Sales_Key
		)
		,AUC
	AS (
		SELECT auc.[Product_Key]
			,[Average_Unit_Cost] = CASE 
				WHEN (SUM([Shipped_Quantity]) + SUM([Return_Units])) <> 0
					THEN (SUM([Shipped_Landed_Cost]) + SUM([Return_Landed_Cost])) / (SUM([Shipped_Quantity]) + SUM([Return_Units]))
				ELSE NULL
				END
		FROM AUC_Details auc
		INNER JOIN [CWC_DW].[Dimension].[Products] p ON auc.Product_Key = p.Product_Key
		GROUP BY auc.Product_Key
		)
	UPDATE p
	SET p.[Average_Unit_Cost] = CASE 
			WHEN auc.[Average_Unit_Cost] > 0
				THEN auc.[Average_Unit_Cost]
			ELSE NULL
			END
	FROM [CWC_DW].[Dimension].[Products] p
	LEFT JOIN auc ON p.Product_Key = auc.Product_Key
	WHERE ISNULL(p.[Average_Unit_Cost], 0) <> ISNULL(auc.[Average_Unit_Cost], 0);

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

