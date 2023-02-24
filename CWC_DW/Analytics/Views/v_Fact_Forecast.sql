/****** Script for SelectTopNRows command from SSMS  ******/


CREATE VIEW [Analytics].[v_Fact_Forecast] AS

SELECT [Forecast Date] = [Forecast_Date]
      ,[Print Cycle] = NULLIF([Print_Cycle],'')
      --,[Pct_Week]
      ,[Demand]
      ,[Orders]
      ,[Units]
      --,[is_Removed_From_Source]
      --,[is_Excluded]
      --,[ETL_Created_Date]
      --,[ETL_Modified_Date]
      --,[ETL_Modified_Count]
  FROM [CWC_DW].[Fact].[Forecast];