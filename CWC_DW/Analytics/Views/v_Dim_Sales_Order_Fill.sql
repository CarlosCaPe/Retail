/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Analytics].[v_Dim_Sales_Order_Fill]

AS

SELECT [Sales_Order_Fill_Key] = CAST([Sales_Order_Fill_Key] AS SMALLINT)
      --,[Fill_CD]
      ,[Sales_Order_Fill]
      ,[Fill_Days]
      ,[1_Day_Fill]
      ,[7_Day_Fill]
      ,[30_Day_Fill]
      ,[60_Day_Fill]
      ,[90_Day_Fill]
      ,[120_Day_Fill]
      ,[Over_120_Day_Fill]
      --,[Range_Start]
      --,[Range_Stop]
  FROM [CWC_DW].[Dimension].[Sales_Order_Fill] (NOLOCK)
  ;