
CREATE PROC [Analytics].[usp_Return_Orders_FY2021] AS


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

BEGIN TRY

		SELECT
			   [Sales_Order_Number] = s.[Sales_Order_Number]
			  ,s.[Sales_Line_Number]
			  ,[Sales_Line_Created_Date] = DATEADD(hh,-5,s.[Sales_Line_Created_Date])
			  ,[Original_Sales_Order_Number] = s2.Sales_Order_Number
			  ,[Original_Sales_Line_Number] = s2.[Sales_Line_Number]
			  ,[Original_Sales_Line_Created_Date] = DATEADD(hh,-5,s2.[Sales_Line_Created_Date])
			  ,shp.Sales_Header_Status
			  ,shp.Sales_Header_Type
			  ,slp.Sales_Line_Status
			  ,slp.Sales_Line_Type
			  ,p.Item_ID
			  ,p.Item_Name
			  ,p.Color_Name
			  ,p.Size_Name
			  ,p.Department_Name
			  ,p.Class_Name
			  ,[Sales_Line_Amount] = s.[Sales_Line_Amount] --* -1
			  ,[Sales_Line_Discount_Amount] = s.[Sales_Line_Discount_Amount] --* -1
			  ,[Sales_Line_Ordered_Quantity] = s.[Sales_Line_Ordered_Quantity]-- * -1
			  ,s.[Sales_Line_Remain_Sales_Physical]
			  ,Sales_Header_Return_Reason
			  ,Sales_Header_Return_Reason_Group
			  ,Sales_Line_Return_Deposition_Action
			  ,Sales_Line_Return_Deposition_Description
			  ,s.[Sales_Line_Created_By]
		  FROM [CWC_DW].[Fact].[Sales]   s
		  INNER JOIN [CWC_DW].[Dimension].[Dates]   d ON d.Calendar_Date = CAST(DATEADD(hh,-5,s.[Sales_Line_Created_Date]) AS DATE)
		  INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes]   soa ON s.[Sales_Order_Attribute_Key] = soa.[Sales_Order_Attribute_Key]
		  INNER JOIN [CWC_DW].[Dimension].[Sales_Header_Properties]   shp ON s.Sales_Header_Property_Key = shp.Sales_Header_Property_Key
		  INNER JOIN [CWC_DW].[Dimension].[Sales_Line_Properties]   slp ON s.Sales_Line_Property_Key = slp.Sales_Line_Property_Key
		  INNER JOIN [CWC_DW].[Dimension].[Products]   p ON s.Sales_Line_Product_Key = p.Product_Key
		  LEFT JOIN [CWC_DW].[Fact].[Sales]   s2 ON s.Return_Invent_Trans_ID = s2.Invent_Trans_ID
		  WHERE soa.[Order_Classification] = 'Return' AND Fiscal_Year = 2021;

END TRY

BEGIN CATCH

	DECLARE @InputParameters NVARCHAR(MAX)
	If @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT @InputParameters = '';
	EXEC Administration.usp_ErrorLogger_Insert @InputParameters;

END CATCH