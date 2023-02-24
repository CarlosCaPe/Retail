
/****** Script for SelectTopNRows command from SSMS  ******/


CREATE VIEW [Power_BI].[v_Fact_Vendor_Packing_Slips]
AS

SELECT --TOP (1000) 
	 [Vendor Packing Slip Key] = [Vendor_Packing_Slip_Key]
	,[Purchase Order Key] = [Purchase_Order_Key]
	,[Product Key] = Product_Key
	,[Date Key] = d.Date_Key
	,[Fiscal Week Short] = d.Fiscal_Week_of_Year_Name
	,[Fiscal Week] = [Fiscal_Month_Year_Week_Name]
	,[Fiscal Week Index] = DENSE_RANK() OVER(ORDER BY d.[Fiscal_Year],100 + d.[Fiscal_Week_of_Year])
	,[Receipt Date] = [Vendor_Packing_Accounting_Date]
	,[Receipt Quantity] = [Vendor_Packing_Slip_Quantity]     
FROM [CWC_DW].[Fact].[Vendor_Packing_Slips] (NOLOCK) vps
INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) d ON vps.Vendor_Packing_Accounting_Date = d.Calendar_Date
WHERE [Vendor_Packing_Accounting_Date] >= '8/15/2020';
