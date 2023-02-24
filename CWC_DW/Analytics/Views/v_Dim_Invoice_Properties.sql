
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Analytics].[v_Dim_Invoice_Properties]

AS


SELECT [Invoice_Property_Key]
      ,[Payment_Term]
      ,[Invoice_Line_Unit]
      ,[Invoice_Header_Delivery_Mode]
	  ,[Expedited_Shipping]
      --,[is_Removed_From_Source]
      --,[is_Excluded]
      --,[ETL_Created_Date]
      --,[ETL_Modified_Date]
      --,[ETL_Modified_Count]
  FROM [CWC_DW].[Dimension].[Invoice_Properties] (NOLOCK);
