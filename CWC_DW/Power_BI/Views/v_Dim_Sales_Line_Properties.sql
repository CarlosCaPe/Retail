
/****** Script for SelectTopNRows command from SSMS  ******/

CREATE VIEW [Power_BI].[v_Dim_Sales_Line_Properties]

AS

SELECT [Sales_Line_Property_Key]
      ,[Sales_Line_Status]
      ,[Sales_Line_Type]
      ,[Sales_Line_Tax_Group]
      ,[Sales_Line_Unit]
      ,[Sales_Line_Return_Deposition_Action]
      ,[Sales_Line_Return_Deposition_Description]
      --,[is_Removed_From_Source]
      --,[is_Excluded]
      --,[ETL_Created_Date]
      --,[ETL_Modified_Date]
      --,[ETL_Modified_Count]
  FROM [CWC_DW].[Dimension].[Sales_Line_Properties];
