
CREATE PROC [Import].[usp_Dimension_Product_Purchase_Orders_Sales_Orders_Quantity_Update]
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY
	DECLARE @procedureUpdateKey_ AS INT = 0
		,@USER AS VARCHAR(20) = current_user
		,@date AS SMALLDATETIME = getdate()
		,@stored_procedure_name VARCHAR(50) = OBJECT_NAME(@@PROCID);

	EXEC Administration.usp_Procedure_Updates_Insert @procedureName = @stored_procedure_name
		,@procedureUpdateKey = @procedureUpdateKey_ OUTPUT;

	WITH Purchase_Order_Open
	AS (
		SELECT [Product_Key] = po.[Product Key]
			,[Purchase_Order_Open_Quantity] = SUM(po.[Purchase Line Open Quantity])
		FROM [CWC_DW].[Power_BI].[v_Fact_Purchase_Orders] po --ON vps.Purchase_Order_Key = po.[Purchase Order Key]
		INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] d ON po.[Purchase_Line_Confirmed_Delivery_Date_Key] = d.Date_Key
		WHERE po.[Purchase Order Header Accounting Date] >= '8/15/2020'
			AND po.[Purchase Order Line Status] IN (
				'Open'
				,'Received'
				)
			AND po.[Purchase Line Open Quantity] > 0
		GROUP BY po.[Product Key]
		)
		,Sales_Order_Open
	AS (
		SELECT [Product_Key] = s.Sales_Line_Product_Key
			,[Sales_Order_Open_Quantity] = SUM(s.Sales_Line_Remain_Sales_Physical)
		FROM [CWC_DW].[Fact].[Sales] s
		INNER JOIN [CWC_DW].[Dimension].[Dates] d ON d.Calendar_Date = CAST(DATEADD(hh, - 5, s.[Sales_Line_Created_Date]) AS DATE)
		INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes] soa ON s.[Sales_Order_Attribute_Key] = soa.[Sales_Order_Attribute_Key]
		LEFT JOIN [CWC_DW].[Dimension].[Sales_Line_Properties] slp ON s.Sales_Line_Property_Key = slp.Sales_Line_Property_Key
		LEFT JOIN [CWC_DW].[Dimension].[Sales_Header_Properties] shp ON s.Sales_Header_Property_Key = shp.Sales_Header_Property_Key
		LEFT JOIN [CWC_DW].[Dimension].[Products] p ON s.Sales_Line_Product_Key = p.Product_Key
		WHERE soa.[Order_Classification] = 'Sale'
			AND CAST(s.Sales_Line_Created_Date_EST AS DATE) >= '12/1/2020'
			AND (
				shp.Sales_Header_Status NOT IN (
					'Canceled'
					,'Invoced'
					)
				AND slp.Sales_Line_Status = 'Backorder'
				)
			AND s.is_Removed_From_Source = 0
		GROUP BY s.Sales_Line_Product_Key
		)
	UPDATE p
	SET [Purchase_Order_Open_Quantity] = ISNULL(po.[Purchase_Order_Open_Quantity], 0)
		,[Sales_Order_Open_Quantity] = ISNULL(so.[Sales_Order_Open_Quantity], 0)
	FROM [CWC_DW].[Dimension].[Products] p
	LEFT JOIN Purchase_Order_Open po ON po.Product_Key = p.Product_Key
	LEFT JOIN Sales_Order_Open so ON so.Product_Key = p.Product_Key
	WHERE ISNULL(p.[Purchase_Order_Open_Quantity], 0) <> ISNULL(po.[Purchase_Order_Open_Quantity], 0)
		OR ISNULL(p.[Sales_Order_Open_Quantity], 0) <> ISNULL(so.[Sales_Order_Open_Quantity], 0);

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