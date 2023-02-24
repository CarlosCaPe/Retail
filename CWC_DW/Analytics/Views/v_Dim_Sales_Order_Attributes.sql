/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Analytics].[v_Dim_Sales_Order_Attributes] AS


SELECT [Sales_Order_Attribute_Key] = CAST([Sales_Order_Attribute_Key] AS SMALLINT)
      ,[Order_Classification]
      ,[Future_Return]
FROM [CWC_DW].[Dimension].[Sales_Order_Attributes] (NOLOCK)