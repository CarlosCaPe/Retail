

CREATE PROC [Import].[usp_Dimension_Product_Weighted_Average_Unit_Cost_Update]

AS



SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

  
	  WITH PO_Product_Total AS
	  (
	  SELECT
		   po.[Product_Key]
		  ,[Total_Ordered_Quantity] = SUM([Purchase_Line_Ordered_Quantity])
	  FROM [CWC_DW].[Fact].[Purchase_Orders] po
	  WHERE ISNULL([Purchase_Line_Ordered_Quantity],0) > 0
	  GROUP BY PO.Product_Key
	  )
	  ,PO_Weight AS
	  (
	SELECT
	   po.[Purchase_Order_Key]
	  ,po.[Product_Key]
	  ,[Purchase_Line_Purchase_Price]
	  ,[Commission_Charge_Amount] = ([Commission_Charge_Percentage]/(100))  * ([Purchase_Line_Purchase_Price])
	  ,[Tariff_Charge_Amount] = ([Tariff_Charge_Percentage]/(100))  * ([Purchase_Line_Purchase_Price])
	  ,[Duty_Charge_Amount] = ([Duty_Charge_Percentage]/(100))  * ([Purchase_Line_Purchase_Price])
	  ,[Freight_Charge_Amount] = ([Freight_Charge_Percentage]/(100))  * ([Purchase_Line_Purchase_Price])
	  ,[Freight_In_Charge_Amount] = ([Freight_In_Charge_Percentage]/(100))  * ([Purchase_Line_Purchase_Price])
	  ,Cost_Unit_Total = [Purchase_Line_Purchase_Price] 
						+ ([Commission_Charge_Percentage]/(100))  * ([Purchase_Line_Purchase_Price])
						+ ([Tariff_Charge_Percentage]/(100))  * ([Purchase_Line_Purchase_Price])
						+ ([Duty_Charge_Percentage]/(100))  * ([Purchase_Line_Purchase_Price])
						+ ([Freight_Charge_Percentage]/(100))  * ([Purchase_Line_Purchase_Price])
						+ ([Freight_In_Charge_Percentage]/(100))  * ([Purchase_Line_Purchase_Price])

	  ,[Purchase_Line_Ordered_Quantity]
	  ,[PO_Weight] = po.Purchase_Line_Ordered_Quantity/CAST(popt.[Total_Ordered_Quantity] AS NUMERIC(18,6))
	  FROM [CWC_DW].[Fact].[Purchase_Orders] po
	  INNER JOIN PO_Product_Total popt ON po.Product_Key = popt.Product_Key
	  ) --SELECT * FROM PO_Weight
	  ,Calc_Final AS
	  (
	  SELECT 
	   [Product_Key]
	  ,[Weighted_PO_AUC] = SUM(Cost_Unit_Total * PO_Weight)
	  FROM PO_Weight 
	  --WHERE Product_Key = 149986
	  GROUP BY [Product_Key]
	  )

	UPDATE p
	SET p.PO_Weighted_Average_Unit_Cost = [Weighted_PO_AUC]
	FROM [Dimension].[Products] p
	LEFT JOIN Calc_Final cf ON p.Product_Key = cf.Product_Key
	WHERE ISNULL(p.PO_Weighted_Average_Unit_Cost,0) <> ISNULL([Weighted_PO_AUC],0);

END TRY

BEGIN CATCH

	DECLARE @InputParameters NVARCHAR(MAX)
	If @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT @InputParameters = '';
	EXEC Administration.usp_ErrorLogger_Insert @InputParameters;

END CATCH