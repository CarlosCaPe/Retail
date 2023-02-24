/****** Script for SelectTopNRows command from SSMS  ******/

CREATE VIEW [Data_Flow].[v_Dim_Sales_Line_Properties]

AS

SELECT
	   [Sales Line Property Key] = [Sales_Line_Property_Key]
	  ,[Sales Line Status Index] = CASE slp.[Sales_Line_Status] WHEN 'Backorder' THEN 1 WHEN 'Delivered' THEN 2 WHEN 'Invoiced' THEN 3 WHEN 'Canceled' THEN 4 END
      ,[Sales Line Status] = CASE WHEN Sales_Line_Status = 'Backorder' THEN 'Open' ELSE Sales_Line_Status END
      ,[Sales Line Type] = [Sales_Line_Type]
      ,[Sales Line Tax Group] = [Sales_Line_Tax_Group]
      ,[Sales Line Unit] = [Sales_Line_Unit]
      ,[Sales Line Return Deposition Action] = [Sales_Line_Return_Deposition_Action]
      ,[Sales Line Return Deposition Description] = [Sales_Line_Return_Deposition_Description]
      --,[is_Removed_From_Source]
      --,[is_Excluded]
      --,[ETL_Created_Date]
      --,[ETL_Modified_Date]
      --,[ETL_Modified_Count]
  FROM [CWC_DW].[Dimension].[Sales_Line_Properties] slp