

  CREATE VIEW [Power_BI].[v_Fact_Backorder_Relief_Summary] AS

  SELECT --TOP (1000) 
       [Product Key] = bo.[Product_Key]
	  ,[Fiscal Week Index] = bo.Fiscal_Week_Year_Index
	  ,[Fiscal Week] = bo.Fiscal_Week_Year
      ,[Item Number] = p.[Item Number]
	  ,[Item Number - Name] = p.[Item Number - Name]
	  ,[Item] = p.Item
	  ,[Color] = p.[Color]
	  ,[Size] = p.[Size]
	  ,[Average Unit Retail] = p.[Average Unit Retail]
	  
      ,[Backorder Amount] = bo.[Backorder_Amount]
      ,[Backorder Quantity] = bo.[Backorder_Quantity]
      ,[Backorder AUR] = bo.[Backorder_Average_Unit_Retail]
      ,[Backorder Relief Quantity] = CASE is_Show_Relief WHEN 0 THEN NULL ELSE bo.[Backorder_Relief_Quantity] END
      ,[Bakcorder Releif Amount] = CASE is_Show_Relief WHEN 0 THEN NULL ELSE bo.[Bakcorder_Releif_Amount] END
      ,[Backorder Remainder Quantity] = bo.[Backorder_Remainder_Quantity]
      ,[Backorder Remainder Amount] = bo.[Backorder_Remainder_Amount]
	  ,bo.is_Show_Relief
  FROM [CWC_DW].[Fact].[Backorder_Relief_Summary] (NOLOCK) bo
  LEFT JOIN [CWC_DW].[Power_BI].[v_Dim_Products_Backordered] (NOLOCK) p ON bo.[Product_Key] = p.[Product Key];
