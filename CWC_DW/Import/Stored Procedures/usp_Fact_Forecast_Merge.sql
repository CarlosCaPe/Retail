/****** Script for SelectTopNRows command from SSMS  ******/

CREATE PROC [Import].[usp_Fact_Forecast_Merge]

AS

WITH src AS
(
SELECT --TOP (1000) 
--[Insert_Date]
     -- ,[Row_Id]
 --     ,[FISCALYEAR]
 --     ,[FISCALMONTH]
 --     ,[WEEKNUMBER]
--      ,[DOW]
       [Forecast_Date_Key] = d.Date_Key
	  ,[Forecast_Date] = CAST([FDATE] AS DATE)
      ,[Print_Cycle]
      ,[Pct_Week]
      ,[Demand]
      ,[Orders] = CAST([Orders] AS INT)
      ,[Units] = CAST([Units] AS INT)
	  ,[is_Removed_From_Source] = CAST(0 AS BIT)
	  ,[is_Excluded] = CAST(0 AS BIT)
	  ,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
	  ,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
	  ,[ETL_Modified_Count] = CAST(1 AS TINYINT)
	  --INTO CWC_DW.Fact.[Forecast]
  FROM [CWC_DW].[Import].[REF_DAILY_PLAN_PROD] f
  INNER JOIN [CWC_DW].[Dimension].[Dates] d ON CAST(f.[FDATE] AS DATE) = d.Calendar_Date
  )
  ,tgt as (SELECT * FROM [CWC_DW].[Fact].[Forecast])

MERGE INTO tgt USING src
	ON tgt.Forecast_Date_Key = src.Forecast_Date_Key
		WHEN NOT MATCHED THEN
			INSERT([Forecast_Date_Key],[Forecast_Date],[Print_Cycle],[Pct_Week],[Demand],[Orders],[Units],[is_Removed_From_Source],[is_Excluded],[ETL_Created_Date],[ETL_Modified_Date],[ETL_Modified_Count])
			VALUES(src.[Forecast_Date_Key],src.[Forecast_Date],src.[Print_Cycle],src.[Pct_Week],src.[Demand],src.[Orders],src.[Units],src.[is_Removed_From_Source],src.[is_Excluded],src.[ETL_Created_Date],src.[ETL_Modified_Date],src.[ETL_Modified_Count])
		WHEN MATCHED AND
		      ISNULL(tgt.[Forecast_Date],'')  <> ISNULL(src.[Forecast_Date],'')
		   OR ISNULL(tgt.[Print_Cycle],'')  <> ISNULL(src.[Print_Cycle],'')
		   OR ISNULL(tgt.[Pct_Week],'')  <> ISNULL(src.[Pct_Week],'')
		   OR ISNULL(tgt.[Demand],'')  <> ISNULL(src.[Demand],'')
		   OR ISNULL(tgt.[Orders],'')  <> ISNULL(src.[Orders],'')
		   OR ISNULL(tgt.[Units],'')  <> ISNULL(src.[Units],'')
		   OR ISNULL(tgt.[is_Removed_From_Source],'')  <> ISNULL(src.[is_Removed_From_Source],'')
		THEN UPDATE SET
		    [Forecast_Date] = src.[Forecast_Date]
		   ,[Print_Cycle] = src.[Print_Cycle]
		   ,[Pct_Week] = src.[Pct_Week]
		   ,[Demand] = src.[Demand]
		   ,[Orders] = src.[Orders]
		   ,[Units] = src.[Units]
		   ,[is_Removed_From_Source] = src.[is_Removed_From_Source]
		   ,[ETL_Modified_Date] = src.[ETL_Modified_Date]
		   ,[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1)
		WHEN NOT MATCHED BY SOURCE AND tgt.[is_Removed_From_Source] <> 1 THEN UPDATE SET
			 tgt.[is_Removed_From_Source] = 1
			,tgt.[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,tgt.[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1);
