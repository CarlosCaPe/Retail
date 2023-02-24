/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Analytics].[v_Dim_Purchase_Order_Properties]

AS

SELECT [Purchase_Order_Property_Key]
      ,[Purchase_Order_Header_Status]
      ,[Purchase_Order_Line_Status]
      ,[Purchase_Order_Header_Delivery_Mode_ID]
      ,[Purchase_Order_Header_Delivery_Terms_ID]
      ,[Purchase_Order_Header_Document_Approval_Status]
      ,[Purchase_Order_Header_Buyer_Group_ID]
      ,[Purchase_Order_Header_Payment_Terms_Name]
      ,[Purchase_Order_Header_Vendor_Payment_Method_Name]
      --,[is_Removed_From_Source]
      --,[is_Excluded]
      --,[ETL_Created_Date]
      --,[ETL_Modified_Date]
      --,[ETL_Modified_Count]
  FROM [CWC_DW].[Dimension].[Purchase_Order_Properties] (NOLOCK);