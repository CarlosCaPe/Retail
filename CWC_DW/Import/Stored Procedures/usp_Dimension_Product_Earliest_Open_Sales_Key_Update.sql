
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE PROC [Import].[usp_Dimension_Product_Earliest_Open_Sales_Key_Update]

AS

WITH SO_Product_Sequence AS
(
SELECT
	   [Sales_Key]
      ,[Sales_Line_Product_Key]
	  ,[Seq] = ROW_NUMBER() OVER(PARTITION BY [Sales_Line_Product_Key] ORDER BY [Sales_Line_Created_Date])
FROM [CWC_DW].[Fact].[Sales] s
  INNER JOIN [Analytics].[v_Dim_Sales_Line_Properties] slp ON s.Sales_Line_Property_Key = slp.Sales_Line_Property_Key
WHERE slp.[Sales_Line_Status] = 'Backorder' AND CAST([Sales_Line_Created_Date] AS DATE) >= '12/1/2020'
)
,First_Open_SO AS
(
	SELECT
		 [Sales_Key]
		,[Sales_Line_Product_Key]
	FROM SO_Product_Sequence
	WHERE Seq = 1
)

UPDATE p
SET p.Earliest_Open_Sales_Key = CASE WHEN s.[Sales_Key] IS NULL THEN NULL ELSE s.[Sales_Key] END
FROM [CWC_DW].[Dimension].[Products] (NOLOCK) p
LEFT JOIN First_Open_SO s ON p.[Product_Key] = s.[Sales_Line_Product_Key]
WHERE ISNULL(p.Earliest_Open_Sales_Key,'') <> ISNULL(s.[Sales_Key],'');

