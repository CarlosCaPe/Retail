

CREATE PROC [Import].[usp_Fact_Sales_Sales_Order_Attribute_Key_Update]

AS


WITH Pick_Lists AS
	(
		SELECT DISTINCT [Sales_Key]
		FROM [CWC_DW].[Fact].[Warehouse_Shipping_Orders] (NOLOCK)

		UNION
	    
		SELECT DISTINCT Sales_Key
		FROM [CWC_DW].[Fact].[Invoices] (NOLOCK)
	)
,Order_Class AS
(
SELECT --TOP (5000) 
       s.[Sales_Key]
	  ,[Order_Classification] = CASE WHEN slp.Sales_Line_Type = 'Sale' AND (slp.Sales_Line_Status <> 'Canceled' AND sp.Sales_Header_Type <> 'Canceled' AND s.is_Removed_From_Source = 0)THEN 'Sale'
				WHEN slp.Sales_Line_Type = 'Return' AND (slp.Sales_Line_Status <> 'Canceled' AND sp.Sales_Header_Type <> 'Canceled' AND s.is_Removed_From_Source = 0) THEN 'Return'
				WHEN slp.Sales_Line_Type = 'Sale' AND (slp.Sales_Line_Status = 'Canceled' OR sp.Sales_Header_Type = 'Canceled' OR s.is_Removed_From_Source = 1) THEN 'Canceled Sale'
				WHEN slp.Sales_Line_Type = 'Return' AND (slp.Sales_Line_Status = 'Canceled' OR sp.Sales_Header_Type = 'Canceled' OR s.is_Removed_From_Source = 1) THEN 'Canceled Return'
				ELSE 'Misc'
				END
	  ,[Future_Return] = CASE WHEN s2.Sales_Key IS NULL THEN 'Not Linked to Return'
							  WHEN slp2.Sales_Line_Type = 'Return' AND (slp2.Sales_Line_Status <> 'Canceled' AND sp2.Sales_Header_Type <> 'Canceled') THEN 'Linked to a Return' 
							  ELSE 'Not Linked to Return' END
	  ,[On_Pick_List] = CASE WHEN pl.Sales_Key IS NULL THEN 'Not On Pick List' ELSE 'On Pick List' END
FROM [CWC_DW].[Fact].[Sales] s (NOLOCK)
	LEFT JOIN [CWC_DW].[Fact].[Sales] s2 (NOLOCK) ON s.Invent_Trans_ID = s2.Return_Invent_Trans_ID 
	LEFT JOIN [CWC_DW].[Dimension].[Sales_Header_Properties] sp (NOLOCK) ON s.Sales_Header_Property_Key = sp.Sales_Header_Property_Key
	LEFT JOIN [CWC_DW].[Dimension].[Sales_Line_Properties] slp (NOLOCK) ON s.Sales_Line_Property_Key = slp.Sales_Line_Property_Key
	LEFT JOIN [CWC_DW].[Dimension].[Sales_Header_Properties] sp2 (NOLOCK) ON s2.Sales_Header_Property_Key = sp2.Sales_Header_Property_Key
	LEFT JOIN [CWC_DW].[Dimension].[Sales_Line_Properties] slp2 (NOLOCK) ON s2.Sales_Line_Property_Key = slp2.Sales_Line_Property_Key
	LEFT JOIN Pick_Lists pl ON pl.Sales_Key = s.Sales_Key
	) --SELECT TOP 1000 * FROM Order_Class
,src AS
(
SELECT Sales_Key
	  ,Sales_Order_Attribute_Key
	  ,Seq = ROW_NUMBER() OVER(PARTITION BY Sales_Key ORDER BY Sales_Order_Attribute_Key DESC)
	FROM Order_Class so
	INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes] (NOLOCK) soa ON so.Order_Classification = soa.Order_Classification
																		 AND so.Future_Return = soa.Future_Return
																		 AND so.On_Pick_List = soa.On_Pick_List
)--SELECT TOP 1000 * FROM src where Seq = 2
--SELECT TOP 1000 ISNULL(s.Sales_Order_Attribute_Key,''),src.Sales_Order_Attribute_Key,*
UPDATE s
	SET [Sales_Order_Attribute_Key] = src.Sales_Order_Attribute_Key
	   ,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
	   ,[ETL_Modified_Count] = (ISNULL(s.[ETL_Modified_Count],1) + 1)
FROM src
INNER JOIN [CWC_DW].[Fact].[Sales] (NOLOCK) s ON src.Sales_Key = s.Sales_Key AND Seq = 1
WHERE ISNULL(s.Sales_Order_Attribute_Key,'') <> src.Sales_Order_Attribute_Key;