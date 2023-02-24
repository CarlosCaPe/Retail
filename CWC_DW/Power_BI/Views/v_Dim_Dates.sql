




CREATE VIEW [Power_BI].[v_Dim_Dates] AS

SELECT [Date_Key]
      ,[Calendar_Date]
      ,[Calendar_Month]
      ,[Calendar_Day]
      ,[Calendar_Year]
      ,[Calendar_Quarter]
      ,[Calendar_Quarter_Name]
      ,[Calendar_Quarter_Year_Name]
      ,[Day_Name]
      --,[Day_of_Week]
      --,[Day_of_Week_in_Month]
      --,[Day_of_Week_in_Year]
      --,[Day_of_Week_in_Quarter]
      --,[Day_of_Quarter]
      --,[Day_of_Year]
      --,[Week_of_Month]
      --,[Week_of_Quarter]
      --,[Week_of_Year]
      ,[Month_Name]
	  ,[First_Date_of_Week_Key] = CAST(REPLACE(CAST([First_Date_of_Week] AS VARCHAR(10)),'-','') AS INT)
      ,[First_Date_of_Week]
	  ,[Last_Date_of_Week_Key] = CAST(REPLACE(CAST([Last_Date_of_Week] AS VARCHAR(10)),'-','') AS INT)
      ,[Last_Date_of_Week]
	  --,[First_Date_of_Month_Key] = CAST(REPLACE(CAST([First_Date_of_Month] AS VARCHAR(10)),'-','') AS INT)
      ,[First_Date_of_Month]
	  --,[Last_Date_of_Month_Key] = CAST(REPLACE(CAST([Last_Date_of_Month] AS VARCHAR(10)),'-','') AS INT)
      ,[Last_Date_of_Month]
	  --,[First_Date_of_Quarter_Key] = CAST(REPLACE(CAST([First_Date_of_Quarter] AS VARCHAR(10)),'-','') AS INT)
      ,[First_Date_of_Quarter]
	  --,[Last_Date_of_Quarter_Key] = CAST(REPLACE(CAST([Last_Date_of_Quarter] AS VARCHAR(10)),'-','') AS INT)
      ,[Last_Date_of_Quarter]
	  --,[First_Date_of_Year_Key] = CAST(REPLACE(CAST([First_Date_of_Year] AS VARCHAR(10)),'-','') AS INT)
      ,[First_Date_of_Year]
	  --,[Last_Date_of_Year_Key] = CAST(REPLACE(CAST([Last_Date_of_Year] AS VARCHAR(10)),'-','') AS INT)
      ,[Last_Date_of_Year]
      ,[Holiday] = CASE [is_Holiday] WHEN 0 THEN 'Not a Holiday' ELSE 'Holiday' END
      ,[Holiday_Season] = CASE [is_Holiday_Season] WHEN 0 THEN 'Not Holiday Season' ELSE 'Holiday Season' END
      ,[Holiday_Name] = CASE WHEN [Holiday_Name] IS NULL THEN 'Not a Holiday' ELSE [Holiday_Name] END
      --,[Holiday_Season_Name]
      ,[Weekday] = CASE [is_Weekday] WHEN 1 THEN 'Weekday' ELSE 'Not a Weekday' END
      ,[Business_Day] = CASE [is_Business_Day] WHEN 1 THEN 'Business Day' ELSE 'Not a Business Day' END
      ,[Previous_Business_Day]
      ,[Next_Business_Day]
      ,[Leap_Year] = CASE [is_Leap_Year] WHEN 0 THEN 'Not a Leap Year' ELSE 'Leap Year' END
      ,[Days_in_Month]
      ,[Fiscal_Day_of_Year]
      ,[Fiscal_Week_of_Year]
	  ,[Fiscal_Week_of_Year_Name] = 'Wk ' + CAST([Fiscal_Week_of_Year] AS VARCHAR(3)) --+ ' - ' + [Fiscal_Year]
	  ,[Fiscal_Month_Week_Name] = LEFT(DateName( month , DateAdd( month , CAST([Fiscal_Month] AS TINYINT) , -1 ) ),3) + ' (Wk ' +   RIGHT('0' + CAST([Fiscal_Week_of_Year] AS VARCHAR(3)),2) + ')'
	  ,[Fiscal_Month_Week_Year_Name] = LEFT(DateName( month , DateAdd( month , CAST([Fiscal_Month] AS TINYINT) , -1 ) ),3) + ' (Wk ' +   RIGHT('0' + CAST([Fiscal_Week_of_Year] AS VARCHAR(3)),2) + ')' + ' ' + CAST([Fiscal_Year] AS VARCHAR(4)) 
	  ,[Fiscal_Month_Year_Week_Name] = LEFT(DateName( month , DateAdd( month , CAST([Fiscal_Month] AS TINYINT) , -1 ) ),3) + ' ' + CAST([Fiscal_Year] AS CHAR(4)) + ' (Wk ' +   RIGHT('0' + CAST([Fiscal_Week_of_Year] AS VARCHAR(3)),2) + ')'
	  ,[Confirmed_Delivery_Week_Month_Year_Index] = CAST(CASE WHEN Fiscal_Week_of_Year IS NULL THEN NULL ELSE DENSE_RANK() OVER(ORDER BY Fiscal_Year,10 + CAST([Fiscal_Month] AS int) ,10 + Fiscal_Week_of_Year) END AS INT)
      ,[Fiscal_Month]
	  ,[Fiscal_Month_Name] = Fiscal_Month_Name--DateName( month , DateAdd( month , CAST([Fiscal_Month] AS TINYINT) , -1 ) )
	  ,[Fiscal_Month_Year_Index] = CAST(Fiscal_Year + (CAST(Fiscal_Month AS INT) + 10) AS INT)
      ,[Fiscal_Quarter]
      ,[Fiscal_Quarter_Name]
      ,[Fiscal_Quarter_Year_Name]
      ,[Fiscal_Year]
      ,[Fiscal_Year_Name]
      ,[Fiscal_Month_Year] = REPLACE([Fiscal_Month_Year],'-',' ') 
      ,[Fiscal_MMYYYY]
	  ,[Fiscal_First_Day_of_Month_Key] = CAST(REPLACE(CAST([Fiscal_First_Day_of_Month] AS VARCHAR(10)),'-','') AS INT)
      ,[Fiscal_First_Day_of_Month]
	  ,[Fiscal_Last_Day_of_Month_Key] = CAST(REPLACE(CAST([Fiscal_Last_Day_of_Month] AS VARCHAR(10)),'-','') AS INT)
      ,[Fiscal_Last_Day_of_Month]
	  ,[Fiscal_First_Day_of_Quarter_Key] = CAST(REPLACE(CAST([Fiscal_First_Day_of_Quarter] AS VARCHAR(10)),'-','') AS INT)
      ,[Fiscal_First_Day_of_Quarter]
	  ,[Fiscal_Last_Day_of_Quarter_Key] = CAST(REPLACE(CAST([Fiscal_Last_Day_of_Quarter] AS VARCHAR(10)),'-','') AS INT)
      ,[Fiscal_Last_Day_of_Quarter]
	  ,[Fiscal_First_Day_of_Year_Key] = CAST(REPLACE(CAST([Fiscal_First_Day_of_Year] AS VARCHAR(10)),'-','') AS INT)
      ,[Fiscal_First_Day_of_Year]
	  ,[Fiscal_Last_Day_of_Year_Key] = CAST(REPLACE(CAST([Fiscal_Last_Day_of_Year] AS VARCHAR(10)),'-','') AS INT)
      ,[Fiscal_Last_Day_of_Year]
	  ,[Current_Reporting_Date] = CASE WHEN Calendar_Date = CAST(DATEADD(hh,-29,SYSDATETIME()) AS DATE) THEN 'Current Reporting Date' ELSE 'Not Current Reporting Date' END
	  ,[Current_Inventory_Date] = CASE WHEN is_Current_Inventory_Date = 1 THEN 'Current Inventory Date' ELSE 'Not Current Inventory Date' END
	  ,[Current_Backorder_Date] = CASE WHEN is_Current_Backorder_Date = 1 THEN 'Current Backorder Date' ELSE 'Not Current Backorder Date' END
	  ,[Date_Status] = CASE WHEN [Calendar_Date] < CAST(GETDATE() AS DATE) THEN 'Past Date'
							WHEN [Calendar_Date] = CAST(GETDATE() AS DATE) THEN 'Current Date'
							WHEN [Calendar_Date] > CAST(GETDATE() AS DATE) THEN 'Future Date'
						END
	  ,Fiscal_Week_Status = CASE WHEN Calendar_Date BETWEEN (SELECT First_Date_of_Week FROM [CWC_DW].[Dimension].[Dates] (NOLOCK) WHERE Calendar_Date = CAST(GETDATE() AS DATE))
								  AND (SELECT Last_Date_of_Week FROM [CWC_DW].[Dimension].[Dates] (NOLOCK) WHERE Calendar_Date = CAST(GETDATE() AS DATE))
							THEN 'Current Fiscal Week'
							WHEN Calendar_Date < (SELECT First_Date_of_Week FROM [CWC_DW].[Dimension].[Dates] (NOLOCK) WHERE Calendar_Date = CAST(GETDATE() AS DATE))
							THEN 'Past Fiscal Week'
							WHEN Calendar_Date > (SELECT Last_Date_of_Week FROM [CWC_DW].[Dimension].[Dates] (NOLOCK) WHERE Calendar_Date = CAST(GETDATE() AS DATE))
							THEN 'Future Fiscal Week'
							END
	  ,[Baked Key] = (CASE WHEN DATEDIFF(DAY,Calendar_Date,GETDATE()) > 90 THEN 1 ELSE 2 END)
	  ,[Fiscal Date Last Year] = d.Fiscal_Date_Last_Year
	  ,[is Current Week] = CASE WHEN CAST(GETDATE() AS DATE) BETWEEN [First_Date_of_Week] AND [Last_Date_of_Week] THEN 1 ELSE 0 END
	  ,[is Current Month] = CASE WHEN CAST(GETDATE() AS DATE) BETWEEN [Fiscal_First_Day_of_Month] AND [Fiscal_Last_Day_of_Month] THEN 1 ELSE 0 END
	  ,[is Current Reporting Month] = CASE WHEN DATEADD(DAY,-1,CAST(GETDATE() AS DATE)) BETWEEN [Fiscal_First_Day_of_Month] AND [Fiscal_Last_Day_of_Month] THEN 1 ELSE 0 END
	  ,[is BO Misc Calc] = CASE WHEN d.Calendar_Date < DATEADD(DAY,-2,CAST(GETDATE() AS DATE)) THEN 1 ELSE 0 END
	  ,[is Current Year] = CASE WHEN CAST(GETDATE() AS DATE) BETWEEN [Fiscal_First_Day_of_Year] AND [Fiscal_Last_Day_of_Year] THEN 1 ELSE 0 END
	  ,[is YTD] = CASE WHEN d.Calendar_Date BETWEEN (SELECT Fiscal_First_Day_of_Year FROM [CWC_DW].[Dimension].[Dates] WHERE Calendar_Date = CAST(GETDATE() - 1 AS DATE)) AND CAST(GETDATE()-1 AS DATE) THEN 1 ELSE 0 END
	  ,[is LYTD] = CASE WHEN Calendar_Date <= (SELECT Fiscal_Date_Last_Year FROM [CWC_DW].[Dimension].[Dates] WHERE Calendar_Date = CAST(GETDATE() - 1 AS DATE)) AND d.Fiscal_Year = DATEPART(YEAR,DATEADD(YEAR,-1,CAST(GETDATE() - 1 AS DATE))) THEN 1 ELSE 0 END
	  ,[is QTD] = CASE WHEN d.Calendar_Date BETWEEN (SELECT Fiscal_First_Day_of_Quarter FROM [CWC_DW].[Dimension].[Dates] WHERE Calendar_Date = CAST(GETDATE() - 1 AS DATE)) AND CAST(GETDATE()-1 AS DATE) THEN 1 ELSE 0 END
      ,[is Reporting Date] = CASE WHEN d.Calendar_Date BETWEEN '8/1/2020' AND DATEADD(DAY,-1,CAST(GETDATE() AS DATE)) THEN 1 ELSE 0 END
      --,[is_Removed_From_Source]
      --,[is_Excluded]
      --,[ETL_Created_Date]
      --,[ETL_Modified_Date]
      --,[ETL_Modified_Count]
  FROM [CWC_DW].[Dimension].[Dates] (NOLOCK) d
  --WHERE [Calendar_Year] = 2021
  ;
