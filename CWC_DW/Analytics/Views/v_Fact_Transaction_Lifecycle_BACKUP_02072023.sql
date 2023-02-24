

CREATE VIEW [Analytics].[v_Fact_Transaction_Lifecycle_BACKUP_02072023] AS


WITH Sales_Baked_Free_Shipping AS
	(
		SELECT s.Sales_Key
	  ,[is_Backorder_Fill] = MAX(CAST([is_Backorder_Fill] AS TINYINT))
      ,[is_Baked] = MAX(CAST([is_Baked] AS TINYINT))
      ,[is_Free_Shipping] = MAX(CAST([is_Free_Shipping] AS INT))
		FROM [CWC_DW].[Fact].[Sales] (NOLOCK) s 
			INNER JOIN [CWC_DW].[Fact].[Invoices] i ON s.Invent_Trans_ID = i.Invent_Trans_ID
			INNER JOIN [CWC_DW].[Dimension].[Invoice_Attributes] ia ON i.[Invoice_Attribute_Key] = ia.[Invoice_Attribute_Key]
			--LEFT JOIN Free_Shipping fs ON i.Invoice_Number = fs.Invoice_Number
		WHERE i.[Invoice_Number] NOT IN ('000002','000001') AND CAST(i.Invoice_Line_Date AS DATE) >= '1/1/2019'
		GROUP BY s.Sales_Key
	) --SELECT * FROM  Sales_Baked
,B2B AS 
	(
		SELECT Customer_Key
		FROM [CWC_DW].[Dimension].[Customers]
		WHERE Customer_Group = 'Jobber'
		OR Customer_Account = 'DC00240929'
	)
--,BO_Orders AS (SELECT DISTINCT Sales_Key FROM [CWC_DW].[Fact].[Backorders] (NOLOCK) b)
,Backorders AS
	(
		SELECT
			 b.Sales_Key
			 --,Snapshot_Date = sd.Calendar_Date

			,[Transaction Lifecycle Date] = CAST(b.Sales_Line_Created_Date AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' AS DATE)--CAST(sd.Calendar_Date AS DATE)
			,[Transaction Date] = CAST(sd.Calendar_Date AS DATE)
			,[Product Key] = b.Sales_Line_Product_Key
			,[Order Unique] = NULL --DENSE_RANK() OVER(ORDER BY Sales_Order_Number)
			--,[Order Numnber] = Sales_Order_Number
			,[Order Number e1] = CAST(CASE WHEN SUBSTRING(Sales_Order_Number,1,1) = 'E' THEN 1 ELSE 0 END AS BIT)
			,[Order Number e2] = CASE WHEN SUBSTRING(Sales_Order_Number,2,5) = '00000' THEN 5
				 WHEN SUBSTRING(Sales_Order_Number,2,4) = '0000' THEN 4
				 WHEN SUBSTRING(Sales_Order_Number,2,3) = '000' THEN 3
				 WHEN SUBSTRING(Sales_Order_Number,2,2) = '00' THEN 2
				 WHEN SUBSTRING(Sales_Order_Number,2,1) = '0' THEN 1
				 ELSE 0 END
			,[Order Number e3] = CAST(RIGHT(Sales_Order_Number,LEN(Sales_Order_Number)-1) AS INT)
			,[Line Num] = Sales_Line_Number
			,[Type Num] = 4 --CASE slp.Sales_Line_Type WHEN 'Sale' THEN 1 WHEN 'Return' THEN 2 END
			,[Status Index] = 1 --CASE slp.Sales_Line_Status WHEN 'backorder' THEN 1 WHEN 'Delivered' THEN 2 WHEN 'Invoiced' THEN 3 WHEN 'Canceled' THEN 4 END
			,[Status] = 'Open' --CASE WHEN slp.Sales_Line_Status = 'Backorder' THEN 'Open' ELSE slp.Sales_Line_Status END --CASE slp.Sales_Line_Status WHEN 'backorder' THEN 1 WHEN 'Delivered' THEN 2 WHEN 'Invoiced' THEN 3 WHEN 'Canceled' THEN 4 END
			,[Amount] = ((b.[Sales_Line_Amount]/b.[Sales_Line_Ordered_Sales_Quantity]) * b.[Sales_Line_Remain_Sales_Physical])
			,[Units] = b.[Sales_Line_Remain_Sales_Physical] --b.Sales_Line_Ordered_Sales_Quantity
			,[Discount] = b.Sales_Line_Discount_Amount
			,[Cost] = ISNULL(NULLIF(b.Sales_Line_Cost_Price,0),p.[PO_Weighted_Average_Unit_Cost])
			,[Price] = b.Sales_Line_Price--CASE WHEN b.Sales_Line_Price < ISNULL(NULLIF(b.Sales_Line_Cost_Price,0),p.[PO_Weighted_Average_Unit_Cost]) THEN  ISNULL(NULLIF(tp.Price,0),NULLIF(b.Sales_Line_Price,0)) ELSE ISNULL(NULLIF(b.Sales_Line_Price,0),NULLIF(tp.Price,0)) END
			,[Charge] = NULL
			,[B2B] = NULL --CASE WHEN s.Sales_Header_Customer_Key IN (SELECT Customer_Key FROM B2B) THEN 'Yes' ELSE 'No' END
			,[Backorder Fill] = CASE soa.On_Pick_List WHEN 'On Pick List' THEN 'Yes' ELSE 'No' END --'Yes'--CASE WHEN b.Sales_Key IS NULL THEN 'No' ELSE 'Yes' END --CASE WHEN sb.[is_Backorder_Fill] = 1 THEN 'Yes' ELSE 'No' END
			,[Baked] = NULL --'No' --CASE WHEN sb.[is_Baked] = 1 THEN 'Yes' WHEN sb.[is_Baked] = 0 THEN 'No' ELSE NULL END
			,[Free Shipping] = NULL --CASE sb.[is_Free_Shipping] WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' ELSE NULL END
			,[On Hold] = CASE shp.[Sales_Header_On_Hold] WHEN 1 THEN 'Yes' ELSE 'No' END
			--,[Pick List] = CASE soa.On_Pick_List WHEN 'On Pick List' THEN 'Yes' ELSE 'No' END
			,[Return Reason] = NULL --shp.[Sales_Header_Return_Reason]
		    ,[Delivery Mode] = shp.[Sales_Header_Delivery_Mode]       
			,l.[State]
			,[Zip] = l.[Zip_Code]
			,[Net Quantity] = NULL
			,[Net Amount] = NULL
			--,b.Invent_Trans_ID
		--SELECT COUNT(*)
		FROM [CWC_DW].[Fact].[Backorders] (NOLOCK) b
			INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) sd ON b.[Snapshot_Date_Key] = sd.[Date_Key]
			--INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) bd ON CAST(b.[Sales_Line_Created_Date] AS DATE) = bd.[Calendar_Date]
			INNER JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON b.Sales_Line_Product_Key = p.Product_Key
			INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes] (NOLOCK) soa ON b.Sales_Order_Attribute_Key = soa.Sales_Order_Attribute_Key
			LEFT JOIN [CWC_DW].[Dimension].[Sales_Header_Properties] shp ON shp.[Sales_Header_Property_Key] = b.[Sales_Header_Property_Key]
			LEFT JOIN [CWC_DW].[Dimension].[Locations] l ON b.[Sales_Header_Location_Key] = l.[Location_Key]
			LEFT JOIN [CWC_DW].[Fact].[Trade_Agreement_Prices] tp ON b.Sales_Line_Product_Key = tp.Product_Key AND CAST(b.Sales_Header_Created_Date AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' AS DATE) BETWEEN tp.[Start_Date] AND tp.[End_Date] AND tp.is_Removed_From_Source = 0
		WHERE sd.Current_Backorder_Date = 'Current Backorder Date'
	)
,Returns_Agg AS
(
SELECT
	  r.Return_Invent_Trans_ID
	  ,Units = SUM(r.Sales_Line_Ordered_Quantity)
	  ,Amount = SUM(r.Sales_Line_Amount)
FROM [CWC_DW].[Fact].[Sales] (NOLOCK) r
WHERE CAST(r.[Sales_Line_Created_Date_EST] AS DATE) >= '12/1/2020'
GROUP BY r.Return_Invent_Trans_ID
)
,Sales AS
	(
		SELECT --TOP 5000 
			 --[Transaction Lifecycle Key] = s.Sales_Key
			 [Transaction Lifecycle Date] = CAST(s.Sales_Header_Created_Date AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' AS DATE) --CAST(s.Sales_Header_Created_Date AS DATE) --CAST(s.Sales_Line_Created_Date_EST AS DATE)
			,[Transaction Date] = CAST(s.Sales_Header_Created_Date AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' AS DATE)--CAST(s.Sales_Line_Created_Date_EST AS DATE)
			,[Product Key] = s.Sales_Line_Product_Key
			,[Order Unique] = DENSE_RANK() OVER(ORDER BY Sales_Order_Number)
			--,[Order Numnber] = Sales_Order_Number
			,[Order Number e1] = CAST(CASE WHEN SUBSTRING(Sales_Order_Number,1,1) = 'E' THEN 1 ELSE 0 END AS BIT)
			,[Order Number e2] = CASE WHEN SUBSTRING(Sales_Order_Number,2,5) = '00000' THEN 5
				 WHEN SUBSTRING(Sales_Order_Number,2,4) = '0000' THEN 4
				 WHEN SUBSTRING(Sales_Order_Number,2,3) = '000' THEN 3
				 WHEN SUBSTRING(Sales_Order_Number,2,2) = '00' THEN 2
				 WHEN SUBSTRING(Sales_Order_Number,2,1) = '0' THEN 1
				 ELSE 0 END
			,[Order Number e3] = CAST(RIGHT(Sales_Order_Number,LEN(Sales_Order_Number)-1) AS INT)
			,[Line Num] = Sales_Line_Number
			,[Type Num] = CASE slp.Sales_Line_Type WHEN 'Sale' THEN 1 WHEN 'Return' THEN 2 END
			,[Status Index] = CASE slp.Sales_Line_Status WHEN 'backorder' THEN 1 WHEN 'Delivered' THEN 2 WHEN 'Invoiced' THEN 3 WHEN 'Canceled' THEN 4 END
			,[Status] = CASE WHEN slp.Sales_Line_Status = 'Backorder' THEN 'Open' ELSE slp.Sales_Line_Status END --CASE slp.Sales_Line_Status WHEN 'backorder' THEN 1 WHEN 'Delivered' THEN 2 WHEN 'Invoiced' THEN 3 WHEN 'Canceled' THEN 4 END
			,[Amount] = s.Sales_Line_Amount
			,[Units] = s.Sales_Line_Ordered_Sales_Quantity
			,[Discount] = s.Sales_Line_Discount_Amount
			,[Cost] = ISNULL(NULLIF(s.Sales_Line_Cost_Price,0),p.[PO_Weighted_Average_Unit_Cost])
			,[Price] = s.Sales_Line_Price--CASE WHEN s.Sales_Line_Price < ISNULL(NULLIF(s.Sales_Line_Cost_Price,0),p.[PO_Weighted_Average_Unit_Cost]) THEN  ISNULL(NULLIF(tp.Price,0),NULLIF(s.Sales_Line_Price,0)) ELSE ISNULL(NULLIF(s.Sales_Line_Price,0),NULLIF(tp.Price,0)) END
			,[Charge] = NULL--s.Sales_Line_Price
			,[B2B] = CASE WHEN s.Sales_Header_Customer_Key IN (SELECT Customer_Key FROM B2B) THEN 'Yes' ELSE 'No' END
			,[Backorder Fill] = NULL -- CASE WHEN boo.Sales_Key IS NULL THEN 0 ELSE 1 END --CASE WHEN b.Sales_Key IS NULL THEN 'No' ELSE 'Yes' END --CASE WHEN sb.[is_Backorder_Fill] = 1 THEN 'Yes' ELSE 'No' END
			,[Baked] = CASE WHEN sb.[is_Baked] = 1 THEN 'Yes' ELSE 'No' END
			,[Free Shipping] = NULL --CASE sb.[is_Free_Shipping] WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' ELSE NULL END
			--,[Pick List] = NULL--CASE soa.On_Pick_List WHEN 'On Pick List' THEN 'Yes' ELSE 'No' END
			,[On Hold] = CASE shp.[Sales_Header_On_Hold] WHEN 1 THEN 'Yes' ELSE 'No' END
			,[Return Reason] = NULL --shp.[Sales_Header_Return_Reason]
		    ,[Delivery Mode] = shp.[Sales_Header_Delivery_Mode]
			,[Net Quantity] = s.Sales_Line_Ordered_Sales_Quantity - r.Units
			,[Net Amount] = s.Sales_Line_Amount - r.Amount
			,l.[State]
			,[Zip] = l.[Zip_Code]
			,s.Invent_Trans_ID
		FROM [CWC_DW].[Fact].[Sales] (NOLOCK) s
			LEFT JOIN [CWC_DW].[Dimension].[Sales_Line_Properties] slp ON slp.Sales_Line_Property_Key = s.Sales_Line_Property_Key
			LEFT JOIN [CWC_DW].[Fact].[Trade_Agreement_Prices] tp ON s.Sales_Line_Product_Key = tp.Product_Key AND CAST(s.Sales_Line_Created_Date_EST AS DATE) BETWEEN tp.[Start_Date] AND tp.[End_Date] AND tp.is_Removed_From_Source = 0
			LEFT JOIN [CWC_DW].[Dimension].[Products] p ON s.Sales_Line_Product_Key = p.Product_Key
			LEFT JOIN [CWC_DW].[Dimension].[Sales_Header_Properties] shp ON shp.[Sales_Header_Property_Key] = s.[Sales_Header_Property_Key]
			LEFT JOIN [CWC_DW].[Dimension].[Locations] l ON s.[Sales_Header_Location_Key] = l.[Location_Key]
			LEFT JOIN Sales_Baked_Free_Shipping sb ON s.Sales_Key = sb.Sales_Key
			LEFT JOIN Returns_Agg r ON s.Invent_Trans_ID = r.Return_Invent_Trans_ID
			--LEFT JOIN BO_Orders boo ON s.Sales_Key = boo.Sales_Key
			--LEFT JOIN Backorders b ON s.Sales_Key = b.Sales_Key AND CAST(s.Sales_Line_Created_Date_EST AS DATE) = b.Snapshot_Date
		WHERE CAST(s.Sales_Header_Created_Date AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' AS DATE) >= '1/1/2019' 
		AND slp.Sales_Line_Type = 'Sale' AND s.Sales_Line_Ordered_Sales_Quantity > 0 AND s.Sales_Line_Product_Key IS NOT NULL
	) --SELECT TOP 100 * FROM Sales WHERE [Transaction Lifecycle Date] <> [Transaction Lifecycle Date Convert]
	--SELECT GETDATE(),GETUTCDATE()
,Returns AS
	(
		SELECT --TOP 500
			 --[Transaction Lifecycle Key] = s.[Transaction Lifecycle Key]
			 [Transaction LifeCycle Date] = CAST(s.[Transaction Date] AS DATE)
			,[Transaction Date] = CAST(r.Sales_Header_Created_Date AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' AS DATE) --CAST(r.Sales_Header_Created_Date AS DATE) --CAST(r.Sales_Line_Created_Date_EST AS DATE)
			--,[Transaction Key] = r.Sales_Key
			,[Product Key] = ISNULL(r.[Sales_Line_Product_Key],s.[Product Key])
			--,[Transaction Date] = CAST(r.Sales_Line_Created_Date_EST AS DATE)
			,[Order Unique] = DENSE_RANK() OVER(ORDER BY r.[Sales_Order_Number])
			
			--,[Order Numnber] = r.Sales_Order_Number
			,[Order Number e1] = CAST(CASE WHEN SUBSTRING(r.[Sales_Order_Number],1,1) = 'E' THEN 1 ELSE 0 END AS BIT)
			,[Order Number e2] = CASE WHEN SUBSTRING(r.[Sales_Order_Number],2,5) = '00000' THEN 5
				 WHEN SUBSTRING(r.[Sales_Order_Number],2,4) = '0000' THEN 4
				 WHEN SUBSTRING(r.[Sales_Order_Number],2,3) = '000' THEN 3
				 WHEN SUBSTRING(r.[Sales_Order_Number],2,2) = '00' THEN 2
				 WHEN SUBSTRING(r.[Sales_Order_Number],2,1) = '0' THEN 1
				 ELSE 0 END
			,[Order Number e3] = CAST(RIGHT(r.[Sales_Order_Number],LEN(r.[Sales_Order_Number])-1) AS INT)

			,[Line Num] = r.Sales_Line_Number
			,[Type Num] = CASE slp.Sales_Line_Type WHEN 'Sale' THEN 1 WHEN 'Return' THEN 2 END
			,[Status Index] = CASE slp.Sales_Line_Status WHEN 'backorder' THEN 1 WHEN 'Delivered' THEN 2 WHEN 'Invoiced' THEN 3 WHEN 'Canceled' THEN 4 END
			,[Status] = slp.Sales_Line_Status--CASE slp.Sales_Line_Status WHEN 'backorder' THEN 1 WHEN 'Delivered' THEN 2 WHEN 'Invoiced' THEN 3 WHEN 'Canceled' THEN 4 END

			,[Amount] = r.Sales_Line_Amount * -1
			,[Units] = r.Sales_Line_Ordered_Sales_Quantity * -1
			,[Discount] = r.Sales_Line_Discount_Amount
			,[Cost] = r.Sales_Line_Cost_Price
			,[Price] = r.Sales_Line_Price
			,[Charge] = NULL
			,[B2B] = CASE WHEN r.Sales_Header_Customer_Key IN (SELECT Customer_Key FROM B2B) THEN 'Yes' ELSE 'No' END
			,[Backorder Fill] = CASE sb.[is_Backorder_Fill] WHEN 1 THEN 'Yes' ELSE 'No' END
			,[Baked] = CASE WHEN sb.[is_Baked] = 1 THEN 'Yes' ELSE 'No' END
			,[Free Shipping] = CASE sb.[is_Free_Shipping] WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' ELSE NULL END
			,[On Hold] = CASE shp.[Sales_Header_On_Hold] WHEN 1 THEN 'Yes' ELSE 'No' END
			--,[Pick List] = NULL
			,[Return Reason] = shp.[Sales_Header_Return_Reason]
		    ,[Delivery Mode] = shp.[Sales_Header_Delivery_Mode]       
			,l.[State]
			,[Zip] = l.[Zip_Code]
			,s.Invent_Trans_ID
			,[Net Quantity] = NULL
			,[Net Amount] = NULL
		FROM Sales s
			INNER JOIN [CWC_DW].[Fact].[Sales] r ON s.Invent_Trans_ID = r.Return_Invent_Trans_ID
			INNER JOIN [Dimension].[Sales_Line_Properties] slp ON slp.Sales_Line_Property_Key = r.Sales_Line_Property_Key
			LEFT JOIN [CWC_DW].[Dimension].[Sales_Header_Properties] shp ON shp.[Sales_Header_Property_Key] = r.[Sales_Header_Property_Key]
			LEFT JOIN [CWC_DW].[Dimension].[Locations] l ON r.[Sales_Header_Location_Key] = l.[Location_Key]
			LEFT JOIN Sales_Baked_Free_Shipping sb ON r.Sales_Key = sb.Sales_Key
		WHERE CAST(r.Sales_Header_Created_Date AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' AS DATE) >= '1/1/2019' 
		AND slp.[Sales_Line_Type] = 'Return' 
		--AND r.Sales_Line_Ordered_Sales_Quantity >= 0
	) --SELECT * FROM Returns
,Shipments AS
	(
	SELECT --TOP 5000 
	 [Transaction Lifecycle Date] = s.[Transaction Date]
	,[Transaction Date] = CAST(i.Invoice_Line_Date AS DATE)
	,[Product Key] =ISNULL(i.Invoice_Line_Product_Key,s.[Product Key])
	
	,[Order Unique] = DENSE_RANK() OVER(ORDER BY s.[Order Unique])
	--,i.Invoice_Number
	,[Order Number e1] = CAST(CASE WHEN SUBSTRING(i.Invoice_Number,1,2) = 'IN' THEN 1 ELSE 0 END AS BIT)
	,[Order Number e2] = 
	CASE WHEN SUBSTRING(i.Invoice_Number,1,3) = 'INV' AND SUBSTRING(i.Invoice_Number,4,2) = '00' THEN 2
		 WHEN SUBSTRING(i.Invoice_Number,1,3) = 'INV' AND SUBSTRING(i.Invoice_Number,4,1) = '0' THEN 1
		 WHEN SUBSTRING(i.Invoice_Number,1,3) = 'INV' THEN 0
		 WHEN SUBSTRING(i.Invoice_Number,1,2) = 'CN' AND SUBSTRING(i.Invoice_Number,3,4) = '0000'THEN 4
		 WHEN SUBSTRING(i.Invoice_Number,1,2) = 'CN' AND SUBSTRING(i.Invoice_Number,3,3) = '000'THEN 3
		 WHEN SUBSTRING(i.Invoice_Number,1,2) = 'CN' AND SUBSTRING(i.Invoice_Number,3,2) = '00'THEN 2
		 WHEN SUBSTRING(i.Invoice_Number,1,2) = 'CN' AND SUBSTRING(i.Invoice_Number,3,1) = '0'THEN 1
		 WHEN SUBSTRING(i.Invoice_Number,1,2) = 'CN' THEN 0
		 ELSE 0 END
	,[Order Number e3] = CASE WHEN SUBSTRING(i.Invoice_Number,1,3) = 'INV' THEN CAST(RIGHT(i.Invoice_Number,LEN(i.Invoice_Number)-3) AS INT)
								ELSE CAST(RIGHT(i.Invoice_Number,LEN(i.Invoice_Number)-2) AS INT) END
	,[Line Num] = i.Invoice_Line_Number
	,[Type Num] = 3 --3 Will be converted to Invoice in Analysis Services
	,[Status Index] = s.[Status Index]
	,[Status] = s.[Status]

	,[Amount] = i.Invoice_Line_Amount
	,[Units] = i.Invoice_Line_Quantity
	,[Discount] = i.Invoice_Line_Discount_Amount
	,[Cost] = NULLIF(s.Cost,0)
	,[Price] = NULLIF(s.Price,0)
	,[Charge] = NULLIF(i.[Invoice_Header_Total_Charge_Amount],0)
	,[B2B] = CASE WHEN i.[Invoice_Customer_Key] IN (SELECT Customer_Key FROM B2B) THEN 'Yes' ELSE 'No' END
	,[Backorder Fill] = CASE ia.[is_Backorder_Fill] WHEN 1 THEN 'Yes' ELSE 'No' END
	,[Baked] = CASE WHEN ia.[is_Baked] = 1 THEN 'Yes' WHEN ia.[is_Baked] = 0 THEN 'No' ELSE NULL END
	,[Free Shipping] = CASE ia.[is_Free_Shipping] WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' ELSE NULL END
	,[On Hold] = 'No'
	--,[Pick List] = NULL
	,[Return Reason] = NULL
	,[Delivery Mode] = ip.[Invoice_Header_Delivery_Mode]
	,s.[State]
	,[Zip] = s.[Zip]
	,s.Invent_Trans_ID
	,[Net Quantity] = NULL
	,[Net Amount] = NULL
	FROM Sales s
	INNER JOIN [CWC_DW].[Fact].[Invoices] i ON s.Invent_Trans_ID = i.Invent_Trans_ID
	INNER JOIN [CWC_DW].[Dimension].[Invoice_Attributes] ia ON i.[Invoice_Attribute_Key] = ia.[Invoice_Attribute_Key]
	INNER JOIN [CWC_DW].[Dimension].[Invoice_Properties] ip ON i.Invoice_Property_Key = ip.Invoice_Property_Key
	WHERE i.[Invoice_Number] NOT IN ('000002','000001') AND CAST(i.Invoice_Line_Date AS DATE) >= '1/1/2019' AND s.[Type Num] = 1
	)

SELECT --TOP 100000
	 [Transaction Lifecycle Date]
	,[Transaction Date]
	,[Product Key]
	,[Order Unique]
	,[Order Number e1]
	,[Order Number e2]
	,[Order Number e3]
	,[Line Num]
	,[Type Num]
	,[Status Index]
	,[Status]
	,[Amount]
	,[Net Amount]
	,[Units]
	,[Net Quantity]
	,[Discount]
	,[Cost]
	,[Price]
	,[Charge]
	,[B2B]
	,[Backorder Fill]
	,[Baked]
	,[Free Shipping]
	,[On Hold]
	--,[Pick List]
	,[Return Reason]
	,[Delivery Mode]
	,[State]
	,[Zip]	
FROM Sales

UNION ALL

SELECT --TOP 100000
	 [Transaction Lifecycle Date]
	,[Transaction Date]
	,[Product Key]
	,[Order Unique]
	,[Order Number e1]
	,[Order Number e2]
	,[Order Number e3]
	,[Line Num]
	,[Type Num]
	,[Status Index]
	,[Status]
	,[Amount]
	,[Net Amount]
	,[Units]
	,[Net Quantity]
	,[Discount]
	,[Cost]
	,[Price]
	,[Charge]
	,[B2B]
	,[Backorder Fill]
	,[Baked]
	,[Free Shipping]
	,[On Hold]
	--,[Pick List]
	,[Return Reason]
	,[Delivery Mode]
	,[State]
	,[Zip]

FROM Returns

UNION ALL

SELECT --TOP 100000
	 [Transaction Lifecycle Date]
	,[Transaction Date]
	,[Product Key]
	,[Order Unique]
	,[Order Number e1]
	,[Order Number e2]
	,[Order Number e3]
	,[Line Num]
	,[Type Num]
	,[Status Index]
	,[Status]
	,[Amount]
	,[Net Amount]
	,[Units]
	,[Net Quantity]
	,[Discount]
	,[Cost]
	,[Price]
	,[Charge]
	,[B2B]
	,[Backorder Fill]
	,[Baked]
	,[Free Shipping]
	,[On Hold]
	--,[Pick List]
	,[Return Reason]
	,[Delivery Mode]
	,[State]
	,[Zip]
FROM Shipments

UNION ALL

SELECT --TOP 100000
	 [Transaction Lifecycle Date]
	,[Transaction Date]
	,[Product Key]
	,[Order Unique]
	,[Order Number e1]
	,[Order Number e2]
	,[Order Number e3]
	,[Line Num]
	,[Type Num]
	,[Status Index]
	,[Status]
	,[Amount]
	,[Net Amount]
	,[Units]
	,[Net Quantity]
	,[Discount]
	,[Cost]
	,[Price]
	,[Charge]
	,[B2B]
	,[Backorder Fill]
	,[Baked]
	,[Free Shipping]
	,[On Hold]
	--,[Pick List]
	,[Return Reason]
	,[Delivery Mode]
	,[State]
	,[Zip]
FROM Backorders;

