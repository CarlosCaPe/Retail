

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Data_Flow].[v_Dim_Vendors] AS

SELECT [Vendor Key] = [Vendor_Key]
      ,[Vendor Account Number] = [Vendor_Account_Number]
      ,[Vendor Group] = [Vendor_Group]
      ,[Vendor Name] = [Vendor_Organization_Name]
	  ,[Vendor Account] = v.Vendor_Account_Number
	  ,[Vendor] = v.Vendor_Organization_Name
	  ,[Vendor Delivery Terms CD] = v.Default_Delivery_Terms_CD
	  ,[Vendor Delivery Terms Parent CD] = CASE WHEN LEFT(v.Default_Delivery_Terms_CD,2) = 'DD' THEN 'DDP'
												WHEN v.Default_Delivery_Terms_CD = 'FOBO' THEN 'FOBO'
												ELSE 'FOB' END
	  ,[Vendor Country] = v.Country_Name
  FROM [CWC_DW].[Dimension].[Vendors] (NOLOCK) v;
 -- WHERE Vendor_Group = 'Invoice'
