


CREATE VIEW [Analytics].[v_Dim_Dates] AS


SELECT --[Date Key] = [Date_Key]
        [Calendar Date] = [Calendar_Date]
      --,[Calendar Month] = [Calendar_Month]
      --,[Calendar Day] = [Calendar_Day]
      --,[Calendar Year] = [Calendar_Year]
      --,[Calendar Quarter] = [Calendar_Quarter]
      --,[Calendar Quarter Name] = [Calendar_Quarter_Name]
      --,[Calendar Quarter Year Name] = [Calendar_Quarter_Year_Name]
      ,[Day] = [Day_Name]
	  ,[Daily Flash Date] = LEFT(Day_Name,2) + ' ' +  LEFT(CONVERT(VARCHAR(8), [Calendar_Date], 1),5)
	  ,[Date Short] = FORMAT([Calendar_Date],'M/d')--LEFT(CONVERT(VARCHAR(8), [Calendar_Date], 1),5)
	  ,[Date Short Index] = CAST(FORMAT([Calendar_Date],'MMdd') AS VARCHAR(5))
      --,[Day_of_Week]
      --,[Day_of_Week_in_Month]
      --,[Day_of_Week_in_Year]
      --,[Day_of_Week_in_Quarter]
      --,[Day_of_Quarter]
      --,[Day_of_Year]
      --,[Week_of_Month]
      --,[Week_of_Quarter]
      --,[Week_of_Year]
      --,[Month Name] = [Month_Name]
	  --,[First_Date_of_Week_Key] = CAST(REPLACE(CAST([First_Date_of_Week] AS VARCHAR(10)),'-','') AS INT)
   --   ,[First_Date_of_Week]
	  --,[Last_Date_of_Week_Key] = CAST(REPLACE(CAST([Last_Date_of_Week] AS VARCHAR(10)),'-','') AS INT)
   --   ,[Last_Date_of_Week]
	  ----,[First_Date_of_Month_Key] = CAST(REPLACE(CAST([First_Date_of_Month] AS VARCHAR(10)),'-','') AS INT)
   --   ,[First_Date_of_Month]
	  ----,[Last_Date_of_Month_Key] = CAST(REPLACE(CAST([Last_Date_of_Month] AS VARCHAR(10)),'-','') AS INT)
   --   ,[Last_Date_of_Month]
	  ----,[First_Date_of_Quarter_Key] = CAST(REPLACE(CAST([First_Date_of_Quarter] AS VARCHAR(10)),'-','') AS INT)
   --   ,[First_Date_of_Quarter]
	  ----,[Last_Date_of_Quarter_Key] = CAST(REPLACE(CAST([Last_Date_of_Quarter] AS VARCHAR(10)),'-','') AS INT)
   --   ,[Last_Date_of_Quarter]
	  ----,[First_Date_of_Year_Key] = CAST(REPLACE(CAST([First_Date_of_Year] AS VARCHAR(10)),'-','') AS INT)
   --   ,[First_Date_of_Year]
	  ----,[Last_Date_of_Year_Key] = CAST(REPLACE(CAST([Last_Date_of_Year] AS VARCHAR(10)),'-','') AS INT)
      --,[Last Date of Year] = [Last_Date_of_Year]
      
      --,[Previous Business Day] = [Previous_Business_Day]
      --,[Next Business Day] = [Next_Business_Day]
      --,[Leap Year] = CASE [is_Leap_Year] WHEN 0 THEN 'No' ELSE 'Yes' END
      --,[Days in Month] = [Days_in_Month]
	  ,[Fiscal Date Last Year] = d.Fiscal_Date_Last_Year
      ,[Fiscal Day Index] = [Fiscal_Day_of_Year]
      ,[Fiscal Week Index] = CAST([Fiscal_Week_of_Year] AS TINYINT)
	  ,[Fiscal Week] = 'Wk ' +   CAST([Fiscal_Week_of_Year] AS VARCHAR(4)) --+ ' - ' + [Fiscal_Year]
	  ,[Fiscal Week Year Index] = CAST(CAST(Fiscal_Year AS VARCHAR(4)) + CAST((CAST([Fiscal_Week_of_Year] AS INT) + 10) AS VARCHAR(3)) AS INT)
	  ,[Fiscal Week Year] = 'Wk ' +   CAST([Fiscal_Week_of_Year] AS VARCHAR(4)) + ' (' + CAST([Fiscal_Year] AS VARCHAR(4)) + ')'
	  ,[Fiscal Month Week] = LEFT(DateName( month , DateAdd( month , CAST([Fiscal_Month] AS TINYINT) , -1 ) ),3) + ' (Wk ' +   RIGHT('0' + CAST([Fiscal_Week_of_Year] AS VARCHAR(2)),2) + ')'
	  --,[Fiscal Month Week Year Name] = LEFT(DateName( month , DateAdd( month , CAST([Fiscal_Month] AS TINYINT) , -1 ) ),3) + ' (Wk ' +   RIGHT('0' + CAST([Fiscal_Week_of_Year] AS VARCHAR(2)),2) + ')' + ' ' + CAST([Fiscal_Year] AS VARCHAR(4))
	  ,[Fiscal Month Year Week] = LEFT(DateName( month , DateAdd( month , CAST([Fiscal_Month] AS TINYINT) , -1 ) ),3) + ' ' + CAST([Fiscal_Year] AS VARCHAR(4)) + ' (Wk ' +   RIGHT('0' + CAST([Fiscal_Week_of_Year] AS VARCHAR(2)),2) + ')'
	  ,[Fiscal Month Year Week Index] = CAST(CAST(Fiscal_Year AS VARCHAR(4)) + CAST((CAST(Fiscal_Month AS INT) + 10) AS VARCHAR(3)) + CAST((CAST([Fiscal_Week_of_Year] AS INT) + 10) AS VARCHAR(3)) AS INT)
	  
	  --,[Confirmed Delivery Week Month Year Index] = CAST(CASE WHEN Fiscal_Week_of_Year IS NULL THEN NULL ELSE DENSE_RANK() OVER(ORDER BY CAST(Fiscal_Year AS VARCHAR(4)),'10' + [Fiscal_Month] ,'10' + Fiscal_Week_of_Year) END AS INT)
      ,[Fiscal Month Index] = CAST([Fiscal_Month] AS TINYINT)
	  ,[Fiscal Month] = DateName( month , DateAdd( month , CAST([Fiscal_Month] AS TINYINT) , -1 ) )
	  ,[Fiscal Month Year Index] = CAST(CAST(Fiscal_Year AS VARCHAR(4)) + CAST((CAST(Fiscal_Month AS INT) + 10) AS VARCHAR(3)) AS INT)
      ,[Fiscal Quarter Index] = [Fiscal_Quarter]
      ,[Fiscal Quarter] = [Fiscal_Quarter_Name]
      ,[Fiscal Quarter Year] = [Fiscal_Quarter_Year_Name]
      ,[Fiscal Year Index] = [Fiscal_Year]
      ,[Fiscal Year] = [Fiscal_Year_Name]
      ,[Fiscal Month Year] = REPLACE([Fiscal_Month_Year],'-',' ') 
   --   ,[Fiscal MMYYYY] = [Fiscal_MMYYYY]
	  --,[Fiscal First Day of Month Key] = CAST(REPLACE(CAST([Fiscal_First_Day_of_Month] AS VARCHAR(10)),'-','') AS INT)
   --   ,[Fiscal First Day of Month] = [Fiscal_First_Day_of_Month]
	  --,[Fiscal Last Day of Month_Key] = CAST(REPLACE(CAST([Fiscal_Last_Day_of_Month] AS VARCHAR(10)),'-','') AS INT)
   --   ,[Fiscal Last Day of Month] = [Fiscal_Last_Day_of_Month]
	  --,[Fiscal First Day of Quarter Key] = CAST(REPLACE(CAST([Fiscal_First_Day_of_Quarter] AS VARCHAR(10)),'-','') AS INT)
   --   ,[Fiscal First Day of Quarter] = [Fiscal_First_Day_of_Quarter]
	  --,[Fiscal Last Day of Quarter Key] = CAST(REPLACE(CAST([Fiscal_Last_Day_of_Quarter] AS VARCHAR(10)),'-','') AS INT)
   --   ,[Fiscal Last Day of Quarter] = [Fiscal_Last_Day_of_Quarter]
	  --,[Fiscal First Day of Year Key] = CAST(REPLACE(CAST([Fiscal_First_Day_of_Year] AS VARCHAR(10)),'-','') AS INT)
   --   ,[Fiscal First Day of Year] = [Fiscal_First_Day_of_Year]
	  --,[Fiscal Last Day of Year Key] = CAST(REPLACE(CAST([Fiscal_Last_Day_of_Year] AS VARCHAR(10)),'-','') AS INT)
   --   ,[Fiscal Last Day of Year] = [Fiscal_Last_Day_of_Year]
	  ,[Current Reporting Date] = CASE WHEN Calendar_Date = CAST(DATEADD(hh,-29,SYSDATETIME()) AS DATE) THEN 'Yes' ELSE 'No' END
	  ,[Current Inventory Date] = CASE WHEN is_Current_Inventory_Date = 1 THEN 'Yes' ELSE 'No' END
	  ,[Current Backorder Date] = CASE WHEN is_Current_Backorder_Date = 1 THEN 'Yes' ELSE 'No' END
	  ,[Holiday] = CASE [is_Holiday] WHEN 0 THEN 'No' ELSE 'Yes' END
      ,[Holiday Name] = CASE WHEN [Holiday_Name] IS NULL THEN NULL ELSE [Holiday_Name] END
      ,[Weekday] = CASE [is_Weekday] WHEN 1 THEN 'Yes' ELSE 'No' END
      ,[Business Day] = CASE [is_Business_Day] WHEN 1 THEN 'Yes' ELSE 'No' END
	  ,[Date Status] = CASE WHEN [Calendar_Date] < CAST(GETDATE()-1 AS DATE) THEN 'Past Date'
							WHEN [Calendar_Date] = CAST(GETDATE()-1 AS DATE) THEN 'Current Date'
							WHEN [Calendar_Date] > CAST(GETDATE()-1 AS DATE) THEN 'Future Date'
						END
	  ,[Fiscal Week Status] = CASE WHEN Calendar_Date BETWEEN (SELECT First_Date_of_Week FROM [CWC_DW].[Dimension].[Dates] (NOLOCK) WHERE Calendar_Date = CAST(GETDATE() AS DATE))
								  AND (SELECT Last_Date_of_Week FROM [CWC_DW].[Dimension].[Dates] (NOLOCK) WHERE Calendar_Date = CAST(GETDATE() AS DATE))
							THEN 'Current Fiscal Week'
							WHEN Calendar_Date < (SELECT First_Date_of_Week FROM [CWC_DW].[Dimension].[Dates] (NOLOCK) WHERE Calendar_Date = CAST(GETDATE() AS DATE))
							THEN 'Past Fiscal Week'
							WHEN Calendar_Date > (SELECT Last_Date_of_Week FROM [CWC_DW].[Dimension].[Dates] (NOLOCK) WHERE Calendar_Date = CAST(GETDATE() AS DATE))
							THEN 'Future Fiscal Week'
							END
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
  WHERE (Fiscal_Year BETWEEN 2019 AND DATEPART(YEAR,CAST(GETDATE() AS DATE)) + 1)

		 --(
		 -- (DATEPART(YEAR,CAST(GETDATE() AS DATE)) <> 2022 AND (Fiscal_Year BETWEEN DATEPART(YEAR,CAST(GETDATE() AS DATE))-1 AND DATEPART(YEAR,CAST(GETDATE() AS DATE)))) --Current and Previous Year
		 -- OR (DATEPART(YEAR,CAST(GETDATE() AS DATE)) = 2022 AND (Fiscal_Year BETWEEN DATEPART(YEAR,CAST(GETDATE() AS DATE))-3 AND DATEPART(YEAR,CAST(GETDATE() AS DATE)) AND Fiscal_Year <> 2020)) -- Current. Previous and 2019 just for FY 2022
	  --   )
  --AND Calendar_Date >= '8/15/2020'
  --ORDER BY [Calendar Date]
  ;

