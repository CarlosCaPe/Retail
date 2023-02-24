/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Analytics].[v_Dim_Locations]

AS

SELECT [Location_Key]
      ,[Street]
      ,[State]
      ,[City]
      ,[Zip_Code]
      ,[Country]
  FROM [CWC_DW].[Dimension].[Locations]
  ;