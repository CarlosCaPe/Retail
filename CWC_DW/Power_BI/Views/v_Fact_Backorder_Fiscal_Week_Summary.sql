


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Power_BI].[v_Fact_Backorder_Fiscal_Week_Summary] 

AS 

SELECT TOP (1000) 
	   [Fiscal Week Index] = [Fiscal_Week_Index]
      ,[Fiscal Week] = [Fiscal_Week]
	  ,[Fiscal Week Short] = [Fiscal_Week_Short]
      ,[Week Beginning] = [Week_Beginning]
      ,[Demand Amount] = [Demand_Amount]--/1000
      ,[Orders] = [Orders]
      ,[Beginning Backorder Amount] = [Beginning_Backorder_Amount]--/1000
      ,[New Backorder Amount] = [New_Backorder_Amount]--/1000
      ,[New Backorder Rate] = [New_Backorder_Rate]
      ,[Backorder Shipped Amount] = [Backorder_Shipped_Amount]--/1000
      ,[Shipped Backorder Rate] = [Shipped_Backorder_Rate]
      ,[Backorder Misc] = [Backorder_Misc]--/1000
      ,[Ending Backorder Amount] = [Ending_Backorder_Amount]--/1000
      ,[Demand 12 Week Amount] = [Demand_12_Week_Amount]--/1000
      ,[Backorder Rate] = [Backorder_Rate]
      ,[Backorder Diff] = [Backorder_Diff]
      --,[Demand_Shipped_Amount]
      --,[Demand_Shipped_Units]
      --,[Units]
      --,[Backorder_Orders]
      --,[Beginning_Backorder_Units]
      --,[New_Backorder_Units]
      --,[Backorder_Shipped_Units]
      --,[Ending_Backorder_Units]
      ,[Unit Fill Rate] = [Unit_Fill_Rate]
      ,[Order Fill Rate] = [Order_Fill_Rate]
	  ,[Receipt Backorder] = Receipt_Backorder
	  ,[Receipt Other] = Receipt_Other
	  ,[Backorder Canceled] = Backorder_Canceled
  FROM [CWC_DW].[Fact].[Backorder_Fiscal_Week_Summary] (NOLOCK);
