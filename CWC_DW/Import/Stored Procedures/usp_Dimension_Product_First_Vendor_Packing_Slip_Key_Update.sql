CREATE PROC [Import].[usp_Dimension_Product_First_Vendor_Packing_Slip_Key_Update] AS

WITH Vendor_Packing_Slips AS
(
SELECT
	[Vendor_Packing_Slip_Key]
	,[Product_Key]
	,Seq = ROW_NUMBER() OVER(PARTITION BY Product_Key ORDER BY [Vendor_Packing_Accounting_Date],[Invent_Trans_ID],[Vendor_Packing_Slip_ID])
FROM [CWC_DW].[Fact].[Vendor_Packing_Slips] (NOLOCK)
)
,First_Vendor_Packing_Slip AS
(
SELECT 
	 [Vendor_Packing_Slip_Key]
	,[Product_Key]
FROM Vendor_Packing_Slips
WHERE Seq = 1
)
--SELECT *
UPDATE p
	SET First_Vendor_Packing_Slip_Key = vps.Vendor_Packing_Slip_Key
FROM [CWC_DW].[Dimension].[Products] (NOLOCK) p
	LEFT JOIN First_Vendor_Packing_Slip vps ON vps.Product_Key = p.Product_Key
WHERE ISNULL(First_Vendor_Packing_Slip_Key,0) <> ISNULL(vps.Vendor_Packing_Slip_Key,0);
