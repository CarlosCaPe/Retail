
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Power_BI].[v_Nic_and_Zoe_ADHOC_DW_FORMATTED]

AS
SELECT --TOP (1000) 
	   [Item]
      --,[Color]
      --,[Size]
      ,[SKU]
      ,[Item Name]
      ,[Sales Order Number]
      --,[Sales Line Number]
      ,[Transaction Date] = [Sale Date]
      ,[Invoice Date]
      ,[Sales Type] = [Sales Line Type]
      --,[Channel]
      --,[Retail Channel]
      --,[Sales Header Status]
      ,[Sales Status] = [Sales Line Status]
      --,[Tax Group]
      --,[Unit Amount]
      --,[Unit Price Amount]
      --,[Net Amount]
      --,[Net Units]
      --,[Line Amount]
      
      --,[Sales Landed Cost]
      --,[Sales Remain Sales Physical]
      --,[Sales Cancel Amount]
      --,[Sales Cancel Units]
      --,[Original Sales Date]
      --,[Original Sales Order Number]
      --,[Original Sales Order Line Number]
	  
      --,[Sale Price]
      
      ,[Sales Units]

	  ,[Return Units]
	  ,[Shipped Units]

	  ,[Sales Amount]
	  ,[Sales Discount Amount]
      ,[Return Amount]
	  ,[Shipped Amount]
	  ,[Shipped Landed Cost]
	  
	  ,[Shipping Income]
      --,[Return Landed Cost]
      --,[Return Deposition Action]
      --,[Return Deposition Description]
      ,[Sales_Header_Return_Reason_Group]
      ,[Sales Header Return Reason]
      ,[Sales Header Delivery Mode]
      ,[Expedited Shipping] = CASE WHEN [Sales Header Delivery Mode] IN ('2-Day Air','FedEx Overnight') THEN 'Yes' ELSE 'No' END
	  ,[Sales Header On Hold]

      --,[Cancel Amount]
      --,[Cancel Units]
      --,[Return Cancel Amount]
      --,[Return Cancel Units]
      ,[Invoice Number]
      --,[Invoice Count]
      
      
      --,[Shipped Tax Amount]
      
      --,[Return Invoice Amount]
      --,[Return Invoice Units]
      --,[Return Invoice Tax Amount]
      ,[Customer Account]
      ,[First Name]
      ,[Last Name]
      ,[Contact Phone]
      ,[Contract Email]
	  ,[Street]
	  ,State
	  ,City
	  ,Zip_Code
      --,[Employee]
      --,[License Source]
  FROM [CWC_DW].[Power_BI].[v_Nic_and_Zoe_ADHOC_DW_071522]


  --SELECT DISTINCT [Sales Header Delivery Mode]
  --FROM [CWC_DW].[Power_BI].[v_Nic_and_Zoe_ADHOC_DW_071522]
