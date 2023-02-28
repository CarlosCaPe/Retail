

CREATE PROC [Import].[usp_Fact_Backorder_Fiscal_Week_Summary_Populate]

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

BEGIN TRY

	--Establish report date range
	DECLARE @Start_Date DATE, @Stop_Date DATE;


	IF OBJECT_ID('tempdb..#Dates') IS NOT NULL DROP TABLE #Dates;

	CREATE TABLE #Dates
		(
			 Date_Key INT PRIMARY KEY
			,Calendar_Date DATE NOT NULL
			,Fiscal_Week TINYINT NOT NULL
			,Fiscal_Year SMALLINT NOT NULL
			,Fiscal_Week_Name VARCHAR(25) NOT NULL
			,Fiscal_Week_Index INT NOT NULL
			,First_Date_of_Week DATE NOT NULL
			,Last_Date_of_Week DATE NOT NULL
			,is_Week_Start BIT NOT NULL
			,is_Week_End BIT NOT NULL
			,Demand NUMERIC(18,6) NULL
			,Demand_Amount NUMERIC(18,6) NULL
			,Demand_Shipped_Amount NUMERIC(18,6) NULL
			,Demand_Shipped_Quantity INT NULL
			,Demand_12_Week NUMERIC(18,6) NULL	
			,Backorder_Amount NUMERIC(18,6) NULL
			,Backorder_Shipped_Amount NUMERIC(18,6) NULL
			,Backorder_Shipped_Quantity INT NULL
			,Demand_Canceled NUMERIC(18,6) NULL
			,Orders INT NULL
			,Orders_Backorder INT NULL
			,Units INT NULL
			,Units_Canceled INT NULL
			,Units_Backorder INT NULL
			,Receipt_Backorder INT NULL
			,Receipt_Other INT NULL
		);



	SELECT 
	 @Stop_Date = DATEADD(DAY,-1,d1.First_Date_of_Week)
	,@Start_Date = d2.First_Date_of_Week
	FROM [CWC_DW].[Power_BI].[v_Dim_Dates] d1
	LEFT JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] d2 ON DATEADD(DAY,-84,d1.Calendar_Date) = d2.Calendar_Date
	WHERE d1.Calendar_Date = CAST(GETDATE() AS DATE);




	INSERT INTO #Dates 
	(Date_Key
	,Calendar_Date
	,Fiscal_Week
	,Fiscal_Year
	,Fiscal_Week_Name
	,Fiscal_Week_Index
	,First_Date_of_Week
	,Last_Date_of_Week
	,is_Week_Start
	,is_Week_End

	)

	SELECT 
		 d1.[Date_Key]
		,d1.[Calendar_Date]
		,[Fiscal_Week] = d1.Fiscal_Week_of_Year
		,d1.[Fiscal_Year]
		,[Fiscal_Week_Name] = d1.[Fiscal_Month_Year_Week_Name]
		,[Fiscal_Week_Index] = DENSE_RANK() OVER(ORDER BY d1.[Fiscal_Year],d1.[Fiscal_Week_of_Year])
		,d1.First_Date_of_Week
		,d1.Last_Date_of_Week
		,[is_Week_Start] = CASE WHEN d1.Calendar_Date <> d1.First_Date_of_Week THEN 0 ELSE 1 END
		,[is_Week_End] = CASE WHEN d1.Calendar_Date <> d1.Last_Date_of_Week THEN 0 ELSE 1 END
	FROM [CWC_DW].[Power_BI].[v_Dim_Dates] d1


	WHERE d1.Calendar_Date BETWEEN @Start_Date AND @Stop_Date
	GROUP BY
	d1.[Date_Key]
	,d1.[Calendar_Date]
	,d1.Fiscal_Week_of_Year
	,d1.[Fiscal_Year]
	,d1.[Fiscal_Month_Year_Week_Name]
	,d1.First_Date_of_Week
	,d1.Last_Date_of_Week;


	--Update Sales level values
	WITH Sales AS
	(
	SELECT d1.Date_Key
	,[Demand] = SUM(s.Sales_Line_Amount)
	,[Units] = SUM(s.Sales_Line_Ordered_Quantity)
	,[Orders] = COUNT(DISTINCT s.Sales_Order_Number)
	FROM #Dates   d1
		LEFT JOIN [CWC_DW].[Power_BI].[v_Fact_Sales_Sales_With_Cancels]   s ON CAST(s.[Sales_Line_Created_Date] AS DATE) = d1.Calendar_Date --BETWEEN d1.First_Date_of_Week AND d1.Last_Date_of_Week
	GROUP BY d1.Date_Key
	)
	UPDATE d
	SET d.Demand = s.Demand
		,d.Units = s.Units
		,d.Orders = s.Orders
	FROM #Dates   d
	INNER JOIN Sales s ON d.Date_Key = s.Date_Key;

	--Update Demand 12 Week
	WITH Demand_12_Week AS
	(
	SELECT d1.Date_Key
	,[Demand_12_Week] = SUM(s.Sales_Line_Amount)
	FROM #Dates   d1
		LEFT JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] d2 ON DATEADD(DAY,-84,d1.[First_Date_of_Week]) = d2.[Calendar_Date] --12 weeks in the past
		LEFT JOIN [CWC_DW].[Power_BI].[v_Fact_Sales_Sales_With_Cancels]   s ON CAST(s.[Sales_Line_Created_Date] AS DATE) BETWEEN d2.[First_Date_of_Week] AND DATEADD(DAY,-1,d1.[First_Date_of_Week])
	WHERE is_Week_End = 1
	GROUP BY d1.Date_Key
	)
	UPDATE d
	SET d.Demand_12_Week = dw.Demand_12_Week
	FROM #Dates   d
	INNER JOIN Demand_12_Week dw ON d.Date_Key = dw.Date_Key;

	WITH Backorders AS
	(
	SELECT
		 d.Date_Key
		,Backorder_Amount = SUM(([Sales_Line_Amount]/CAST([Sales_Line_Ordered_Sales_Quantity] AS NUMERIC(18,6))) * CAST([Sales_Line_Remain_Sales_Physical] AS NUMERIC(18,6)))
		,Units_Backorder = SUM(b.[Sales_Line_Remain_Sales_Physical])
		,Orders_Backorder = COUNT(DISTINCT b.Sales_Order_Number)
	FROM #Dates   d
	INNER JOIN [CWC_DW].[Fact].[Backorders]   b ON d.Date_Key = b.Snapshot_Date_Key AND CAST(b.[Sales_Line_Created_Date] AS DATE) = d.Calendar_Date
	GROUP BY d.Date_Key
	)
	UPDATE d
	SET
		Backorder_Amount = b.Backorder_Amount
	   ,Units_Backorder = b.Units_Backorder
	   ,Orders_Backorder = b.Orders_Backorder
	FROM #Dates   d
	INNER JOIN Backorders b ON d.Date_Key = b.Date_Key;


	WITH Shipped AS
	(
	  SELECT
	   d.Date_Key
	  ,Demand_Shipped_Amount = SUM(CASE WHEN i.[Invoice_Line_Amount] > 0 THEN CAST(i.[Invoice_Line_Amount] AS NUMERIC(18,6)) END)
	  ,Demand_Shipped_Quantity =SUM(CASE WHEN i.[Invoice_Line_Amount] > 0 THEN i.[Invoice_Line_Quantity] END)
	  FROM #Dates   d 
	  INNER JOIN [CWC_DW].[Fact].[Invoices]   i ON i.Invoice_Line_Date_Key = d.Date_Key
	  INNER JOIN [CWC_DW].[Power_BI].[v_Fact_Sales_Sales_With_Cancels]   s ON s.Invent_Trans_ID = i.Invent_Trans_ID
	  GROUP BY d.Date_Key
	)
	UPDATE d
	SET
		d.Demand_Shipped_Amount = s.Demand_Shipped_Amount
	   ,d.Demand_Shipped_Quantity = s.Demand_Shipped_Quantity
	FROM #Dates   d
	INNER JOIN Shipped s ON d.Date_Key = s.Date_Key;

	WITH Backorder_Shipped AS
	(
	  SELECT
	  d.Date_Key
	  ,Backorder_Shipped_Amount = SUM(i.[Invoice_Line_Amount])
	  ,Backorder_Shipped_Quantity = SUM(i.[Invoice_Line_Quantity])

	  FROM #Dates   d 
	  INNER JOIN [CWC_DW].[Fact].[Invoices]   i ON i.Invoice_Line_Date_Key = d.Date_Key
	  INNER JOIN [CWC_DW].[Dimension].[Invoice_Attributes]   ia ON i.Invoice_Attribute_Key = ia.Invoice_Attribute_Key
	  WHERE ia.is_Backorder_Fill = 1 AND LEFT(Invoice_Number,3) = 'INV' --AND d.Fiscal_Week_Name = 'Aug 2021 (Wk 31)'
	  GROUP BY d.Date_Key
	)
	UPDATE d
	SET
		d.Backorder_Shipped_Amount = s.Backorder_Shipped_Amount
	   ,d.Backorder_Shipped_Quantity = s.Backorder_Shipped_Quantity
	FROM #Dates   d
	INNER JOIN Backorder_Shipped s ON d.Date_Key = s.Date_Key;

	WITH Receipts AS
	(
	SELECT 
		   Date_Key
		  ,Receipt_Total = SUM([Vendor_Packing_Slip_Quantity])
		  ,Receipt_Backorder = SUM(CASE WHEN [is_Backordered_Product] = 1 THEN [Vendor_Packing_Slip_Quantity] END)
		  ,Receipt_Other = SUM(CASE WHEN [is_Backordered_Product] = 0 THEN [Vendor_Packing_Slip_Quantity] END)
	  FROM #Dates   d
	  INNER JOIN [CWC_DW].[Fact].[Vendor_Packing_Slips]   vps ON vps.[Vendor_Packing_Accounting_Date] = d.Calendar_Date
	  GROUP BY d.Date_Key
	)
	UPDATE d
	SET
		d.Receipt_Other = r.Receipt_Other
	   ,d.Receipt_Backorder = r.Receipt_Backorder
	FROM #Dates   d
	INNER JOIN Receipts r ON d.Date_Key = r.Date_Key;


	WITH Cancels AS
	(
	SELECT 
		 Date_Key
		,Cancel_Amount = SUM(s.Sales_Line_Amount)
		,Units_Canceled = SUM(s.Sales_Line_Ordered_Quantity)
	FROM #Dates d
	INNER JOIN [CWC_DW].[Fact].[Sales] s ON d.Calendar_Date = CAST(s.[Sales_Line_Created_Date] AS DATE)
	INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes] soa ON s.Sales_Order_Attribute_Key = soa.Sales_Order_Attribute_Key
	WHERE  EXISTS
	(
		SELECT DISTINCT b.[Sales_Key]
		FROM [CWC_DW].[Fact].[Backorders] b
			INNER JOIN [CWC_DW].[Dimension].[Dates] d ON b.[Snapshot_Date_Key] = d.[Date_Key]
		WHERE s.[Sales_Key] = b.Sales_Key 
	)
	AND Order_Classification = 'Canceled Sale'

	GROUP BY Date_Key
	) 

	UPDATE d
	SET
		d.Demand_Canceled = c.Cancel_Amount
	   ,d.Units_Canceled = c.Units_Canceled
	FROM #Dates   d
	INNER JOIN Cancels c ON d.Date_Key = c.Date_Key;


	TRUNCATE TABLE [CWC_DW].[Fact].[Backorder_Fiscal_Week_Summary];

	WITH BO_Begin_End_Calc AS
	(
	SELECT
		 d.[Date_Key]
		 ,d.Fiscal_Week_Index
		 ,d.Fiscal_Week_Name
		,[Sales_Line_Remain_Sales_Physical] = SUM(b.[Sales_Line_Remain_Sales_Physical])
		,[Sales_Line_Amount] = SUM(b.[Sales_Line_Amount])
		,[Sales_Line_Ordered_Sales_Quantity] = SUM(b.[Sales_Line_Ordered_Sales_Quantity])
		,[Beginning_Backorder_Amount] = SUM(CASE WHEN [is_Week_Start] = 1 THEN ([Sales_Line_Amount]/CAST([Sales_Line_Ordered_Sales_Quantity] AS NUMERIC(18,6))) * CAST([Sales_Line_Remain_Sales_Physical] AS NUMERIC(18,6)) ELSE NULL END)
		,[Ending_Backorder_Amount] = SUM(CASE WHEN [is_Week_End] = 1 THEN ([Sales_Line_Amount]/CAST([Sales_Line_Ordered_Sales_Quantity] AS NUMERIC(18,6))) * CAST([Sales_Line_Remain_Sales_Physical] AS NUMERIC(18,6)) ELSE NULL END)
		,[Beginning_Backorder_Quantity] = SUM(CASE WHEN [is_Week_Start] = 1 THEN [Sales_Line_Remain_Sales_Physical] ELSE NULL END)
		,[Ending_Backorder_Quantity]  = SUM(CASE WHEN [is_Week_End] = 1 THEN [Sales_Line_Remain_Sales_Physical] ELSE NULL END)
		,[Demand_12_Week] = MAX(CASE WHEN is_Week_End = 1 THEN [Demand_12_Week] END)
		,[is_Week_Start] = MAX(CAST([is_Week_Start] AS TINYINT))
		,[is_Week_End] = MAX(CAST([is_Week_End] AS TINYINT))

	FROM #Dates   d  
		LEFT JOIN [CWC_DW].[Fact].[Backorders]   b ON b.[Snapshot_Date_Key] = d.[Date_Key] AND (is_Week_Start = 1 OR is_Week_End = 1)

	WHERE b.is_Removed_From_Source = 0
	GROUP BY d.Date_Key,d.Fiscal_Week_Index,Fiscal_Week_Name
	) 
	,BO_Begin_End AS
	(
	SELECT
		 d.[Fiscal_Week_Index]	
		,[Fiscal_Week] = d.[Fiscal_Week_Name]
		,[Fiscal_Week_Short] = 'Wk ' + CAST(d.Fiscal_Week AS VARCHAR(5))
		,[Week_Beginning] = MIN(d.[First_Date_of_Week])
		,[Demand_Amount] = SUM(d.[Demand])
		,[Orders] = SUM(d.[Orders])
		,[Beginning_Backorder_Amount] = SUM([Beginning_Backorder_Amount])
		,[New_Backorder_Amount] = SUM(d.Backorder_Amount)
		,[New_Backorder_Rate] = CASE WHEN SUM(d.[Demand]) > 0 THEN SUM(d.Backorder_Amount)/SUM(d.[Demand]) ELSE NULL END
		,[Backorder_Shipped_Amount] = SUM(d.Backorder_Shipped_Amount)
		,[Shipped_Backorder_Rate] = CASE WHEN SUM(d.[Demand]) > 0 THEN SUM(d.Backorder_Shipped_Amount)/SUM(d.[Demand]) ELSE NULL END
		,[Backorder_Misc] = SUM([Beginning_Backorder_Amount])
							+  SUM(d.Backorder_Amount)
							-  SUM(d.Backorder_Shipped_Amount)
							- SUM(d.Demand_Canceled)
							- SUM([Ending_Backorder_Amount])
		,[Ending_Backorder_Amount] = SUM([Ending_Backorder_Amount])
		,[Demand_12_Week_Amount] = MAX(b.[Demand_12_Week])
		,[Backorder_Rate] = SUM([Ending_Backorder_Amount])/MAX(d.[Demand_12_Week])
		,Backorder_Diff = SUM([Ending_Backorder_Amount]) - SUM([Beginning_Backorder_Amount])
		,[Demand_Shipped_Amount] = SUM(d.Demand_Shipped_Amount)
		,[Demand_Shipped_Units] = SUM(d.Demand_Shipped_Quantity)	
		,[Units] = SUM(d.[Units])
		,[Backorder_Orders] = SUM([Orders_Backorder])	
		,[Beginning_Backorder_Units] = SUM([Beginning_Backorder_Quantity])
		,[New_Backorder_Units] = SUM(d.Units_Backorder)
		,[Backorder_Shipped_Units] = SUM(Backorder_Shipped_Quantity)
		,[Ending_Backorder_Units] = SUM([Ending_Backorder_Quantity])
		,[Unit_Fill_Rate] = (SUM(d.[Units]) - SUM(d.Units_Backorder))/CAST(SUM(d.[Units]) AS NUMERIC(18,6)) --
		,[Order_Fill_Rate] = CASE WHEN SUM(d.[Orders]) <> 0 THEN (SUM(d.[Orders])-SUM([Orders_Backorder]))/CAST(SUM(d.[Orders]) AS NUMERIC(18,6)) ELSE NULL END
		,[Receipt_Backorder] = SUM(Receipt_Backorder)
		,[Receipt_Other] = SUM(Receipt_Other)
		,[Backorder_Cancel_Amount] = SUM(d.Demand_Canceled)
	FROM #Dates   d  
	LEFT JOIN BO_Begin_End_Calc b ON d.Date_Key = b.Date_Key
	GROUP BY d.Fiscal_Week_Index,d.Fiscal_Week_Name,d.Fiscal_Week
	)
	INSERT INTO [CWC_DW].[Fact].[Backorder_Fiscal_Week_Summary]
	SELECT * 
	FROM BO_Begin_End 
	;

END TRY

BEGIN CATCH

	DECLARE @InputParameters NVARCHAR(MAX)
	If @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT @InputParameters = '';
	EXEC Administration.usp_ErrorLogger_Insert @InputParameters;

END CATCH
