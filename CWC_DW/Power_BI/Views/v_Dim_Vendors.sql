
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Power_BI].[v_Dim_Vendors] AS

SELECT [Vendor_Key]
      ,[Vendor_Account_Number]
      ,[Vendor_Group]
      ,[Vendor_Organization_Name]
      --,[Default_Delivery_Mode]
      --,[Default_Delivery_Terms]
      --,[Default_Vendor_Payment_Method]
      --,[Address_Description]
      --,[Address_State_ID]
      --,[Address_Street]
      --,[Address_City]
      --,[Address_Zip_Code]
      --,[Address_Country_Region_ID]
      --,[is_Removed_From_Source]
      --,[is_Excluded]
      --,[ETL_Created_Date]
      --,[ETL_Modified_Date]
      --,[ETL_Modified_Count]
  FROM [CWC_DW].[Dimension].[Vendors] (NOLOCK)
 -- WHERE Vendor_Group = 'Invoice'
