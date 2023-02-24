









CREATE VIEW [Power_BI].[v_Selling_Report_Tracking_Numbers]

AS

SELECT 
 s.Sales_Key
 --,COUNT(*)
--,Sales_Order_Number = TRANSREFID
--,[Line_Number] = LINENUMBER
,[Delivery Date] = CAST(DlvDate AS DATE)
--,Item_ID = ITEMID
,[Tracking Number] = TrackingNumber

--,t.*
FROM [AX_PRODUCTION].[dbo].[rsmShipConfirmationStaging] t
INNER JOIN [CWC_DW].[Fact].[Sales] s ON s.Sales_Order_Number = t.TRANSREFID AND s.Sales_Line_Number = t.LINENUMBER

