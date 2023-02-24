

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Power_BI].[v_Dim_Sales_Header_Properties]

AS

SELECT [Sales_Header_Property_Key]
      ,[Sales_Header_Type]
      ,[Sales_Header_Status]
      ,[Sales_Header_Retail_Channel]
      ,[Sales_Header_Return_Reason_Group]
      ,[Sales_Header_Return_Reason]
      ,[Sales_Header_Delivery_Mode]
	  ,[Sales_Header_On_Hold]
      --,[is_Removed_From_Source]
      --,[is_Excluded]
      --,[ETL_Created_Date]
      --,[ETL_Modified_Date]
      --,[ETL_Modified_Count]
  FROM [CWC_DW].[Dimension].[Sales_Header_Properties]
