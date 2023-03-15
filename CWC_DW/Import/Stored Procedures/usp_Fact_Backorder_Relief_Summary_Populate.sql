
CREATE PROC [Import].[usp_Fact_Backorder_Relief_Summary_Populate]
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

BEGIN TRY
	DECLARE @procedureUpdateKey_ AS INT = 0
		,@USER AS VARCHAR(20) = current_user
		,@date AS SMALLDATETIME = getdate()
		,@stored_procedure_name VARCHAR(50) = OBJECT_NAME(@@PROCID);

	EXEC Administration.usp_Procedure_Updates_Insert @procedureName = @stored_procedure_name
		,@procedureUpdateKey = @procedureUpdateKey_ OUTPUT;

	IF OBJECT_ID('tempdb..#PO_Open') IS NOT NULL
		DROP TABLE #PO_Open;

	CREATE TABLE #PO_Open (
		Product_Key INT NOT NULL
		,Fiscal_Week_Year_Index INT NOT NULL
		,Fiscal_Week_Year VARCHAR(20) NOT NULL
		,Ordered_Quantity INT
		,Received_Quantity INT
		,Open_Quantity INT
		,CONSTRAINT PK_Temp_PO PRIMARY KEY (
			Product_Key
			,Fiscal_Week_Year_Index
			)
		);

	IF OBJECT_ID('tempdb..#Backorders_by_SKU') IS NOT NULL
		DROP TABLE #Backorders_by_SKU;

	CREATE TABLE #Backorders_by_SKU (
		Product_Key INT NOT NULL
		,Fiscal_Week_Year_Index INT NOT NULL
		,Fiscal_Week_Year VARCHAR(20) NOT NULL
		,Backorder_Amount NUMERIC(18, 6)
		,Backorder_Quantity NUMERIC(18, 6)
		,Backorder_Average_Unit_Retail NUMERIC(18, 6)
		,is_Show_Relief BIT NOT NULL
		,CONSTRAINT PK_Temp_Backorder PRIMARY KEY (
			Product_Key
			,Fiscal_Week_Year_Index
			)
		);

	--Populate Backorder temp table
	WITH Backorders_By_SKU
	AS (
		SELECT [Product_Key] = b.Sales_Line_Product_Key
			,[Fiscal_Week_Year_Index] = CAST(CAST(sd.Fiscal_Year AS VARCHAR(4)) + CAST(CAST(sd.Fiscal_Week_of_Year AS INT) + 100 AS VARCHAR(3)) AS INT)
			,[Fiscal_Week_Year] = 'Wk ' + CAST(sd.[Fiscal_Week_of_Year] AS VARCHAR(4)) + ' (' + CAST(sd.[Fiscal_Year] AS VARCHAR(4)) + ')'
			,[Backorder_Amount] = SUM(([Sales_Line_Amount] / [Sales_Line_Ordered_Sales_Quantity]) * [Sales_Line_Remain_Sales_Physical])
			,[Backorder_Quantity] = SUM([Sales_Line_Remain_Sales_Physical])
			,[Backorder_Average_Unit_Retail] = (SUM(([Sales_Line_Amount] / [Sales_Line_Ordered_Sales_Quantity]) * [Sales_Line_Remain_Sales_Physical])) / SUM([Sales_Line_Remain_Sales_Physical])
			,is_Show_Relief = 0
		FROM [CWC_DW].[Fact].[Backorders] b
		INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] sd ON b.[Snapshot_Date_Key] = sd.[Date_Key]
		INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] bd ON CAST(b.[Sales_Line_Created_Date] AS DATE) = bd.[Calendar_Date]
		INNER JOIN [CWC_DW].[Dimension].[Products] p ON b.Sales_Line_Product_Key = p.Product_Key
		LEFT JOIN [CWC_DW].[Fact].[Purchase_Orders] po ON p.Earliest_Open_Purchase_Order_Key = po.Purchase_Order_Key
		WHERE sd.Current_Backorder_Date = 'Current Backorder Date'
		GROUP BY b.Sales_Line_Product_Key
			,CAST(CAST(sd.Fiscal_Year AS VARCHAR(4)) + CAST(CAST(sd.Fiscal_Week_of_Year AS INT) + 100 AS VARCHAR(3)) AS INT)
			,'Wk ' + CAST(sd.[Fiscal_Week_of_Year] AS VARCHAR(4)) + ' (' + CAST(sd.[Fiscal_Year] AS VARCHAR(4)) + ')'
		)
	INSERT INTO #Backorders_by_SKU
	SELECT Product_Key
		,Fiscal_Week_Year_Index
		,Fiscal_Week_Year
		,Backorder_Amount
		,Backorder_Quantity
		,Backorder_Average_Unit_Retail
		,is_Show_Relief
	FROM Backorders_By_SKU;

	--Populate PO temp table
	WITH Backorders_By_SKU
	AS (
		SELECT Product_Key
			,Fiscal_Week_Year_Index
			,Fiscal_Week_Year
			,Backorder_Amount
			,Backorder_Quantity
			,Backorder_Average_Unit_Retail
			,is_Show_Relief
		FROM #Backorders_by_SKU
		)
		,Purchase_Order_By_Item
	AS (
		SELECT p.Product_Key
			,Fiscal_Week_Year_Index = CAST(CAST(cd.Fiscal_Year AS VARCHAR(4)) + CAST(CAST(cd.Fiscal_Week_of_Year AS INT) + 100 AS VARCHAR(3)) AS INT)
			,Fiscal_Week_Year = 'Wk ' + CAST(cd.[Fiscal_Week_of_Year] AS VARCHAR(3)) + ' (' + CAST(cd.[Fiscal_Year] AS VARCHAR(4)) + ')'
			,Ordered_Quantity = SUM(po.Purchase_Line_Ordered_Quantity)
			,Received_Quantity = SUM(po.Received_Quantity)
			,[Open_Quantity] = SUM(po.Open_Quantity)
		FROM Backorders_By_SKU bo
		INNER JOIN [CWC_DW].[Fact].[Purchase_Orders] po ON bo.Product_Key = po.Product_Key
		INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Purchase_Order_Properties] pop ON po.Purchase_Order_Property_Key = pop.Purchase_Order_Property_Key
		LEFT JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] ad ON po.Purchase_Order_Header_Accounting_Date = ad.Calendar_Date
		INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] cd ON po.[Purchase_Line_Confirmed_Delivery_Date] = cd.Calendar_Date
		LEFT JOIN [CWC_DW].[Dimension].[Products] p ON po.Product_Key = p.Product_Key
		INNER JOIN [CWC_DW].[Dimension].[Purchase_Order_Fill] pof ON po.Purchase_Order_Fill_Key = pof.Purchase_Order_Fill_Key
		WHERE po.Purchase_Order_Header_Accounting_Date >= '8/15/2020'
			AND po.Purchase_Line_Confirmed_Delivery_Date >= CAST(GETDATE() AS DATE)
			AND pop.Purchase_Order_Header_Status IN (
				'Open'
				,'Received'
				)
			AND pop.Purchase_Order_Line_Status IN (
				'Open'
				,'Received'
				)
			AND pof.Purchase_Order_Fill_Status = 'Active'
			AND pof.Purchase_Order_Line_Fill_Status = 'Active'
			AND po.is_Removed_From_Source = 0
		GROUP BY p.Product_Key
			,CAST(CAST(cd.Fiscal_Year AS VARCHAR(4)) + CAST(CAST(cd.Fiscal_Week_of_Year AS INT) + 100 AS VARCHAR(3)) AS INT)
			,'Wk ' + CAST(cd.[Fiscal_Week_of_Year] AS VARCHAR(3)) + ' (' + CAST(cd.[Fiscal_Year] AS VARCHAR(4)) + ')'
		)
	INSERT INTO #PO_Open
	SELECT [Product_Key]
		,[Fiscal_Week_Year_Index]
		,[Fiscal_Week_Year]
		,[Ordered_Quantity]
		,[Received_Quantity]
		,[Open_Quantity]
	FROM Purchase_Order_By_Item
	WHERE [Open_Quantity] > 1;

	--Declare and assign loop variables
	DECLARE @Start_Fiscal_Week_Year_Index INT
		,@Stop_Fiscal_Week_Year_Index INT
		,@Current_Fiscal_Week_Year_Index INT
		,@Current_Fiscal_Week_Year VARCHAR(20)
		,@Next_Fiscal_Week_Year_Index INT
		,@Next_Fiscal_Week_Year VARCHAR(20);

	SELECT @Current_Fiscal_Week_Year_Index = (
			SELECT MIN(Fiscal_Week_Year_Index)
			FROM #PO_Open
			);

	SELECT @Current_Fiscal_Week_Year = (
			SELECT TOP 1 Fiscal_Week_Year
			FROM #PO_Open
			WHERE Fiscal_Week_Year_Index = @Current_Fiscal_Week_Year_Index
			);

	SELECT @Start_Fiscal_Week_Year_Index = @Current_Fiscal_Week_Year_Index;

	SELECT @Stop_Fiscal_Week_Year_Index = (
			SELECT MAX(Fiscal_Week_Year_Index)
			FROM #PO_Open
			);

	TRUNCATE TABLE CWC_DW.Fact.Backorder_Relief_Summary;

	WHILE @Current_Fiscal_Week_Year_Index BETWEEN @Start_Fiscal_Week_Year_Index
			AND @Stop_Fiscal_Week_Year_Index
	BEGIN
		UPDATE #Backorders_by_SKU
		SET [Fiscal_Week_Year_Index] = @Current_Fiscal_Week_Year_Index;

		UPDATE bo
		SET is_Show_Relief = CASE 
				WHEN po.Product_Key IS NULL
					THEN 0
				ELSE 1
				END
		FROM #Backorders_by_SKU bo
		LEFT JOIN #PO_Open po ON bo.Product_Key = po.Product_Key
			AND @Current_Fiscal_Week_Year_Index = po.Fiscal_Week_Year_Index;

		INSERT INTO CWC_DW.Fact.Backorder_Relief_Summary
		SELECT bo.Product_Key
			,@Current_Fiscal_Week_Year_Index
			,@Current_Fiscal_Week_Year
			,bo.Backorder_Amount
			,bo.Backorder_Quantity
			,Backorder_Average_Unit_Retail
			,Backorder_Relief_Quantity = --CASE WHEN is_Show_Relief = 0 THEN NULL ELSE
			CASE 
				WHEN SUM(po.Open_Quantity) > Backorder_Quantity
					THEN Backorder_Quantity
				ELSE SUM(po.Open_Quantity)
				END
			--END
			,Bakcorder_Releif_Amount = --CASE WHEN is_Show_Relief = 0 THEN NULL ELSE
			CASE 
				WHEN SUM(po.Open_Quantity) * Backorder_Average_Unit_Retail > Backorder_Amount
					THEN Backorder_Amount
				ELSE SUM(po.Open_Quantity) * Backorder_Average_Unit_Retail
				END
			--END
			,Backorder_Remainder_Quantity = CASE 
				WHEN ISNULL(SUM(po.Open_Quantity), 0) >= Backorder_Quantity
					THEN 0
				ELSE Backorder_Quantity - ISNULL(SUM(po.Open_Quantity), 0)
				END
			,Backorder_Remainder_Amount = CASE 
				WHEN (ISNULL(SUM(po.Open_Quantity), 0) * Backorder_Average_Unit_Retail) >= Backorder_Amount
					THEN 0
				ELSE Backorder_Amount - (ISNULL(SUM(po.Open_Quantity), 0) * Backorder_Average_Unit_Retail)
				END
			,is_Show_Relief = ISNULL(is_Show_Relief, 0)
		FROM #Backorders_by_SKU bo
		LEFT JOIN #PO_Open po ON bo.Product_Key = po.Product_Key
			AND bo.Fiscal_Week_Year_Index >= po.Fiscal_Week_Year_Index
		GROUP BY bo.Product_Key
			,bo.Fiscal_Week_Year_Index
			,bo.Fiscal_Week_Year
			,Backorder_Amount
			,Backorder_Quantity
			,Backorder_Average_Unit_Retail
			,is_Show_Relief;

		UPDATE Administration.Procedure_Updates
		SET [Status] = 'SUCCESS'
			,Affected_Rows = @@ROWCOUNT
			,End_Date = getdate()
		WHERE Procedure_Update_Key = @procedureUpdateKey_

		SELECT @Next_Fiscal_Week_Year_Index = CAST(CAST(d2.Fiscal_Year AS VARCHAR(4)) + CAST(CAST(d2.Fiscal_Week_of_Year AS INT) + 100 AS VARCHAR(3)) AS INT)
			,@Next_Fiscal_Week_Year = 'Wk ' + CAST(d2.[Fiscal_Week_of_Year] AS VARCHAR(3)) + ' (' + CAST(d2.[Fiscal_Year] AS VARCHAR(4)) + ')'
		FROM [CWC_DW].[Dimension].[Dates] d1
		INNER JOIN [CWC_DW].[Dimension].[Dates] d2 ON DATEADD(DAY, 1, d1.Calendar_Date) = d2.Calendar_Date
		WHERE CAST(CAST(d1.Fiscal_Year AS VARCHAR(4)) + CAST(CAST(d1.Fiscal_Week_of_Year AS INT) + 100 AS VARCHAR(3)) AS INT) = @Current_Fiscal_Week_Year_Index;

		SELECT @Current_Fiscal_Week_Year_Index = @Next_Fiscal_Week_Year_Index
			,@Current_Fiscal_Week_Year = @Next_Fiscal_Week_Year;
	END;
END TRY

BEGIN CATCH
	IF @procedureUpdateKey_ <> 0
		UPDATE [Administration].Procedure_Updates
		SET [Status] = 'FAILED'
			,Error = ERROR_MESSAGE()
			,End_Date = getdate()
		WHERE Procedure_Update_Key = @procedureUpdateKey_

	DECLARE @InputParameters NVARCHAR(MAX)

	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SELECT @InputParameters = '';

	EXEC Administration.usp_Error_Logger_Insert @InputParameters;
END CATCH

