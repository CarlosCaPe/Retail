/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Power_BI].[v_Dim_Sales_Margin]

AS 

SELECT --TOP (1000) 
	   [Sales_Margin_Key]
      ,[Sales Margin Group] = [Sales_Margin_Threshold]
      ,[Sales_Margin_Index]
      --,[Start_Range]
      --,[Stop_Range]
  FROM [CWC_DW].[Dimension].[Sales_Margin] (NOLOCK)