
CREATE PROC [Import].[usp_Fact_Purchase_Orders_Purchase_Order_Line_Charges_Update]

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

BEGIN TRY


		WITH Commission AS
			(
				SELECT 
					[Purchase_Order_Key]
					,[Commission_Charge_Line_Number] = CAST(pc.CHARGELINENUMBER AS SMALLINT)
					,[Commission_Charge_Percentage] = pc.CHARGEPERCENTAGE 
					,[Charge_Description] = CAST(pc.CHARGEDESCRIPTION AS VARCHAR(30))
					,[Charge_Category] = pc.CHARGECATEGORY
					,[Seq] = ROW_NUMBER() OVER(PARTITION BY [Purchase_Order_Key] ORDER BY pc.CHARGELINENUMBER DESC)
				FROM [CWC_DW].[Fact].[Purchase_Orders]   po
					INNER JOIN [AX_PRODUCTION].[dbo].[PurchPurchaseOrderLineChargeStaging]   pc ON pc.PURCHASEORDERNUMBER = po.Purchase_Order_Number AND pc.PURCHASEORDERLINENUMBER = po.Purchase_Order_Line_Number
				WHERE PURCHASECHARGECODE = 'Commission'
			) 
		,Tariff AS
			(
				SELECT --TOP (1000) 
						[Purchase_Order_Key]
					,[Tariff_Charge_Line_Number] = CAST(pc.CHARGELINENUMBER AS SMALLINT)
					,[Tariff_Charge_Percentage] = pc.CHARGEPERCENTAGE 
					,[Charge_Description] = CAST(pc.CHARGEDESCRIPTION AS VARCHAR(30))
					,[Charge_Category] = pc.CHARGECATEGORY
					,[Seq] = ROW_NUMBER() OVER(PARTITION BY [Purchase_Order_Key] ORDER BY pc.CHARGELINENUMBER DESC)
				FROM [CWC_DW].[Fact].[Purchase_Orders]   po
						INNER JOIN [AX_PRODUCTION].[dbo].[PurchPurchaseOrderLineChargeStaging]   pc ON pc.PURCHASEORDERNUMBER = po.Purchase_Order_Number AND pc.PURCHASEORDERLINENUMBER = po.Purchase_Order_Line_Number
				WHERE PURCHASECHARGECODE = 'Tariff'
			)--SELECT * FROM Tariff WHERE Seq = 1
		,Freight AS
			(
				SELECT --TOP (1000) 
					 [Purchase_Order_Key]
					,[Freight_Charge_Line_Number] = CAST(pc.CHARGELINENUMBER AS SMALLINT)
					,[Freight_Charge_Percentage] = pc.CHARGEPERCENTAGE 
					,[Charge_Description] = CAST(pc.CHARGEDESCRIPTION AS VARCHAR(30))
					,[Charge_Category] = pc.CHARGECATEGORY
					,[Seq] = ROW_NUMBER() OVER(PARTITION BY [Purchase_Order_Key] ORDER BY pc.CHARGELINENUMBER DESC)
				FROM [CWC_DW].[Fact].[Purchase_Orders]   po
					INNER JOIN [AX_PRODUCTION].[dbo].[PurchPurchaseOrderLineChargeStaging]   pc ON pc.PURCHASEORDERNUMBER = po.Purchase_Order_Number AND pc.PURCHASEORDERLINENUMBER = po.Purchase_Order_Line_Number
				WHERE PURCHASECHARGECODE = 'Freight'
			)
		,Duty AS
			(
				SELECT --TOP (1000) 
					 [Purchase_Order_Key]
					,[Duty_Charge_Line_Number] = CAST(pc.CHARGELINENUMBER AS SMALLINT)
					,[Duty_Charge_Percentage] = pc.CHARGEPERCENTAGE 
					,[Charge_Description] = CAST(pc.CHARGEDESCRIPTION AS VARCHAR(30))
					,[Charge_Category] = pc.CHARGECATEGORY
					,[Seq] = ROW_NUMBER() OVER(PARTITION BY [Purchase_Order_Key] ORDER BY pc.CHARGELINENUMBER DESC)

				FROM [CWC_DW].[Fact].[Purchase_Orders]   po
					INNER JOIN [AX_PRODUCTION].[dbo].[PurchPurchaseOrderLineChargeStaging]   pc ON pc.PURCHASEORDERNUMBER = po.Purchase_Order_Number AND pc.PURCHASEORDERLINENUMBER = po.Purchase_Order_Line_Number
				WHERE PURCHASECHARGECODE = 'Duty'
			)
		,Freight_In AS
			(
				SELECT --TOP (1000) 
					 [Purchase_Order_Key]
					,[Freight_In_Charge_Line_Number] = CAST(pc.CHARGELINENUMBER AS SMALLINT)
					,[Freight_In_Charge_Percentage] = pc.CHARGEPERCENTAGE 
					,[Charge_Description] = CAST(pc.CHARGEDESCRIPTION AS VARCHAR(30))
					,[Charge_Category] = pc.CHARGECATEGORY
					,[Seq] = ROW_NUMBER() OVER(PARTITION BY [Purchase_Order_Key] ORDER BY pc.CHARGELINENUMBER DESC)

				FROM [CWC_DW].[Fact].[Purchase_Orders]   po
					INNER JOIN [AX_PRODUCTION].[dbo].[PurchPurchaseOrderLineChargeStaging]   pc ON pc.PURCHASEORDERNUMBER = po.Purchase_Order_Number AND pc.PURCHASEORDERLINENUMBER = po.Purchase_Order_Line_Number
				WHERE PURCHASECHARGECODE = 'FreightIn'
			)
		,PO_Line_Charges AS
			(
				SELECT 
					po.Purchase_Order_Key
					--,[Commission_Charge_Line_Number]
					,[Commission_Charge_Percentage] = ISNULL(c.[Commission_Charge_Percentage],0)
					--,[Tariff_Charge_Line_Number]
					,[Tariff_Charge_Percentage] = ISNULL(t.[Tariff_Charge_Percentage],0)
					--,[Duty_Charge_Line_Number]
					,[Duty_Charge_Percentage] = ISNULL(d.[Duty_Charge_Percentage],0)
					--,[Freight_Charge_Line_Number]
					,[Freight_Charge_Percentage] = ISNULL(f.[Freight_Charge_Percentage],0)
					--,[FreightIn_Charge_Line_Number]
					,[Freight_In_Charge_Percentage] = ISNULL(fi.[Freight_In_Charge_Percentage],0)
				FROM [CWC_DW].[Fact].[Purchase_Orders]   po
					LEFT JOIN Commission c ON po.[Purchase_Order_Key] = c.[Purchase_Order_Key] AND c.[Seq] = 1
					LEFT JOIN Tariff t ON po.[Purchase_Order_Key] = t.[Purchase_Order_Key] AND t.[Seq] = 1
					LEFT JOIN Duty d ON po.[Purchase_Order_Key] = d.[Purchase_Order_Key] AND d.[Seq] = 1
					LEFT JOIN Freight f ON po.[Purchase_Order_Key] = f.[Purchase_Order_Key] AND f.[Seq] = 1
					LEFT JOIN Freight_In fi ON po.[Purchase_Order_Key] = fi.[Purchase_Order_Key] AND fi.[Seq] = 1
			)
		UPDATE p
		SET
			 [Commission_Charge_Percentage] = plc.[Commission_Charge_Percentage]
			,[Tariff_Charge_Percentage] = plc.[Tariff_Charge_Percentage]
			,[Duty_Charge_Percentage] = plc.[Duty_Charge_Percentage]
			,[Freight_Charge_Percentage] = plc.[Freight_Charge_Percentage]
			,[Freight_In_Charge_Percentage] = plc.[Freight_In_Charge_Percentage]
		FROM [CWC_DW].[Fact].[Purchase_Orders] p
		LEFT JOIN PO_Line_Charges plc ON p.Purchase_Order_Key = plc.Purchase_Order_Key
		WHERE
			   ((p.[Commission_Charge_Percentage] IS NULL) OR (p.[Commission_Charge_Percentage] <> plc.[Commission_Charge_Percentage]))
			OR ((p.[Tariff_Charge_Percentage] IS NULL) OR (p.[Tariff_Charge_Percentage] <> plc.[Tariff_Charge_Percentage]))
			OR ((p.[Duty_Charge_Percentage] IS NULL) OR (p.[Duty_Charge_Percentage] <> plc.[Duty_Charge_Percentage]))
			OR ((p.[Freight_Charge_Percentage] IS NULL) OR (p.[Freight_Charge_Percentage] <> plc.[Freight_Charge_Percentage]))
			OR ((p.[Freight_In_Charge_Percentage] IS NULL) OR (p.[Freight_In_Charge_Percentage] <> plc.[Freight_In_Charge_Percentage]));

END TRY

BEGIN CATCH

	DECLARE @InputParameters NVARCHAR(MAX)
	If @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT @InputParameters = '';
	EXEC Administration.usp_ErrorLogger_Insert @InputParameters;

END CATCH