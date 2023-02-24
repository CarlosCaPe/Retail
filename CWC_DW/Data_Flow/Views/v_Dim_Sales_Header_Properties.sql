
/****** Script for SelectTopNRows command from SSMS  ******/

CREATE VIEW [Data_Flow].[v_Dim_Sales_Header_Properties]

AS

SELECT TOP (1000) 
	   [Sales Header Property Key] = [Sales_Header_Property_Key]
      ,[Sales Header Type] = [Sales_Header_Type]
	  ,[Sales Header Status Index] = CASE shp.Sales_Header_Status WHEN 'Backorder' THEN 1 WHEN 'Delivered' THEN 2 WHEN 'Invoiced' THEN 3 WHEN 'Canceled' THEN 4 END
      ,[Sales Header Status] = CASE WHEN shp.Sales_Header_Status = 'Backorder' THEN 'Open' ELSE shp.Sales_Header_Status END
      ,[Sales Header Retail Channel] = [Sales_Header_Retail_Channel]
      ,[Sales Header Retail Channel Name] = [Sales_Header_Retail_Channel_Name]
      ,[Sales_Header Return Reason Group] = [Sales_Header_Return_Reason_Group]
      ,[Sales Header Return Reason] = [Sales_Header_Return_Reason]
      ,[Sales Header Delivery Mode] = [Sales_Header_Delivery_Mode]
      ,[Sales Header On Hold] = CASE [Sales_Header_On_Hold] WHEN 1 THEN 'On Hold' ELSE 'Not On Hold' END
      --,[is_Removed_From_Source]
      --,[is_Excluded]
      --,[ETL_Created_Date]
      --,[ETL_Modified_Date]
      --,[ETL_Modified_Count]
  FROM [CWC_DW].[Dimension].[Sales_Header_Properties] shp
