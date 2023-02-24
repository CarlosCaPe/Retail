
CREATE VIEW [Adhoc].[v_Finance_Invoice_Tracking_Numbers]
  
AS

WITH Tracking AS
	(
		SELECT
			 [TRANSREFID]
			 ,LINENUMBER
			,[DLVDATE] = CAST([DLVDATE] AS DATE)
			--,[ITEMID]
			,[QTY] = CAST([QTY] AS INT)
			--,[LINENUMBER]
			,[TRACKINGNUMBER]
		FROM [Entity_Staging].[dbo].[rsmShipConfirmationStaging]

		UNION ALL

		
		SELECT 
			 [TRANSREFID] = SALESORDERNUMBER
			 ,LINENUMBER = LINENUM
			,[DLVDATE] = DELIVERYDATE
			,[QTY] = CAST([QTY] AS INT)
			,TRACKINGNUMBER
		FROM [AX_PRODUCTION].[dbo].ITSSalesPackingSlipTrackingInformationStaging t
		WHERE CAST(t.DELIVERYDATE AS DATE) >='1/1/2022'
	)
--,Sales AS
--(
SELECT --TOP 1000
 [Ship Date] = t.DLVDATE
,[Invoice Number] = i.Invoice_Number
--,i.Invoice_Line_Number
,[Sales Order Number]= [TRANSREFID]
,[Tracking Number] = t.TRACKINGNUMBER
,[Invoice Amount] = i.Invoice_Line_Amount
--,[Expedited Shipping] = ip.Expedited_Shipping
--,ip.Payment_Term
FROM CWC_DW.Fact.Sales (NOLOCK) s
INNER JOIN Tracking t ON t.TRANSREFID = s.Sales_Order_Number AND t.LINENUMBER =s.Sales_Line_Number
INNER JOIN CWC_DW.Fact.Invoices (NOLOCK) i ON i.Invoice_Key = s.Invoice_Key
--INNER JOIN [CWC_DW].[Dimension].[Invoice_Properties] (NOLOCK) ip ON i.Invoice_Property_Key = ip.Invoice_Property_Key
--)
;
