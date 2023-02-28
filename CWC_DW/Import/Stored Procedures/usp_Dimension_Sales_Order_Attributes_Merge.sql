
CREATE PROC [Import].[usp_Dimension_Sales_Order_Attributes_Merge]

AS


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	WITH Pick_Lists AS
		(
			SELECT DISTINCT [Sales_Key]
			FROM [CWC_DW].[Fact].[Warehouse_Shipping_Orders]  
		)
	,Order_Class AS
	(
	SELECT --TOP (5000) 
		   s.[Sales_Key]
		  ,[Order_Classification] = 
			   CASE WHEN slp.Sales_Line_Type = 'Sale' AND (slp.Sales_Line_Status <> 'Canceled' AND sp.Sales_Header_Type <> 'Canceled' AND s.is_Removed_From_Source <> 1)THEN 'Sale'
					WHEN slp.Sales_Line_Type = 'Return' AND (slp.Sales_Line_Status <> 'Canceled' AND sp.Sales_Header_Type <> 'Canceled' AND s.is_Removed_From_Source <> 1) THEN 'Return'
					WHEN slp.Sales_Line_Type = 'Sale' AND (slp.Sales_Line_Status = 'Canceled' OR sp.Sales_Header_Type = 'Canceled' OR s.is_Removed_From_Source = 1) THEN 'Canceled Sale'
					WHEN slp.Sales_Line_Type = 'Return' AND (slp.Sales_Line_Status = 'Canceled' OR sp.Sales_Header_Type = 'Canceled' OR s.is_Removed_From_Source = 1) THEN 'Canceled Return'
					ELSE 'Misc'
					END
		  ,[Future_Return] = CASE WHEN s2.Sales_Key IS NULL THEN 'Not Linked to Return'
								  WHEN slp2.Sales_Line_Type = 'Return' AND (slp2.Sales_Line_Status <> 'Canceled' AND sp2.Sales_Header_Type <> 'Canceled') THEN 'Linked to a Return' 
								  ELSE 'Not Linked to Return' END
		  ,[On_Pick_List] = CASE WHEN pl.Sales_Key IS NULL THEN 'Not On Pick List' ELSE 'On Pick List' END
	FROM [CWC_DW].[Fact].[Sales] s  
		LEFT JOIN [CWC_DW].[Fact].[Sales] s2   ON s.Invent_Trans_ID = s2.Return_Invent_Trans_ID 
		LEFT JOIN [CWC_DW].[Dimension].[Sales_Header_Properties] sp   ON s.Sales_Header_Property_Key = sp.Sales_Header_Property_Key
		LEFT JOIN [CWC_DW].[Dimension].[Sales_Line_Properties] slp   ON s.Sales_Line_Property_Key = slp.Sales_Line_Property_Key
		LEFT JOIN [CWC_DW].[Dimension].[Sales_Header_Properties] sp2   ON s2.Sales_Header_Property_Key = sp2.Sales_Header_Property_Key
		LEFT JOIN [CWC_DW].[Dimension].[Sales_Line_Properties] slp2   ON s2.Sales_Line_Property_Key = slp2.Sales_Line_Property_Key
		LEFT JOIN Pick_Lists pl ON pl.Sales_Key = s.Sales_Key
		)--SELECT TOP 5000 * FROM Order_Class
	,src AS
	(
	SELECT DISTINCT
		 [Order_Classification]
		,[Future_Return]
		,[On_Pick_List]
		FROM Order_Class
	) --SELECT * FROM src
	,tgt AS (SELECT * FROM [Dimension].[Sales_Order_Attributes]  )

	MERGE INTO tgt USING src
		ON tgt.[Order_Classification] = src.[Order_Classification] AND tgt.[Future_Return] = src.[Future_Return] AND tgt.[On_Pick_List] = src.[On_Pick_List]
			WHEN NOT MATCHED THEN
				INSERT([Order_Classification],[Future_Return],[On_Pick_List])
				VALUES(src.[Order_Classification],src.[Future_Return],[On_Pick_List]);


END TRY

BEGIN CATCH

	DECLARE @InputParameters NVARCHAR(MAX)
	If @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT @InputParameters = '';
	EXEC Administration.usp_ErrorLogger_Insert @InputParameters;

END CATCH
