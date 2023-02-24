/****** Script for SelectTopNRows command from SSMS  ******/


CREATE VIEW [Analytics].[v_Fact_Sessions] AS

SELECT --TOP (1000)
       [Date]
      ,[Sessions]
      --,[Transactions]
      --,[Revenue]
      --,[is_Removed_From_Source]
      --,[ETL_Created_Date]
      --,[ETL_Modified_Date]
      --,[ETL_Modified_Count]
  FROM [CWC_DW].[Fact].[Sessions];