



CREATE PROC [Import].[usp_Fact_Backorder_Relief_Summary_Populate]  AS

IF OBJECT_ID('tempdb..#PO_Open') IS NOT NULL DROP TABLE #PO_Open;

CREATE TABLE #PO_Open
(
 Product_Key INT NOT NULL
,Fiscal_Week_Year_Index INT NOT NULL
,Fiscal_Week_Year VARCHAR(20) NOT NULL
,Ordered_Quantity INT
,Received_Quantity INT
,Open_Quantity INT
,CONSTRAINT PK_Temp_PO PRIMARY KEY (Product_Key,Fiscal_Week_Year_Index)
);

IF OBJECT_ID('tempdb..#Backorders_by_SKU') IS NOT NULL DROP TABLE #Backorders_by_SKU;

CREATE TABLE #Backorders_by_SKU
	(
		 Product_Key INT NOT NULL
		,Fiscal_Week_Year_Index INT NOT NULL
		,Fiscal_Week_Year VARCHAR(20) NOT NULL
		,Backorder_Amount NUMERIC(18,6)
		,Backorder_Quantity NUMERIC(18,6)
		,Backorder_Average_Unit_Retail NUMERIC(18,6)
		,is_Show_Relief BIT NOT NULL
		,CONSTRAINT PK_Temp_Backorder PRIMARY KEY (Product_Key,Fiscal_Week_Year_Index)
	);
--Populate Backorder temp table
WITH Backorders_By_SKU AS
	(
		SELECT
			 [Product_Key] = b.Sales_Line_Product_Key
			,[Fiscal_Week_Year_Index] =  CAST(CAST(sd.Fiscal_Year AS VARCHAR(4)) + CAST(CAST(sd.Fiscal_Week_of_Year AS INT) + 100 AS VARCHAR(3)) AS INT)
			,[Fiscal_Week_Year] = 'Wk ' +   CAST(sd.[Fiscal_Week_of_Year] AS VARCHAR(4)) + ' (' + CAST(sd.[Fiscal_Year] AS VARCHAR(4)) + ')'
			,[Backorder_Amount] = SUM(([Sales_Line_Amount]/[Sales_Line_Ordered_Sales_Quantity]) * [Sales_Line_Remain_Sales_Physical])
			,[Backorder_Quantity] = SUM([Sales_Line_Remain_Sales_Physical])
			,[Backorder_Average_Unit_Retail] = (SUM(([Sales_Line_Amount]/[Sales_Line_Ordered_Sales_Quantity]) * [Sales_Line_Remain_Sales_Physical]))/SUM([Sales_Line_Remain_Sales_Physical])
			,is_Show_Relief = 0
		FROM [CWC_DW].[Fact].[Backorders] (NOLOCK) b
			INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) sd ON b.[Snapshot_Date_Key] = sd.[Date_Key]
			INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] (NOLOCK) bd ON CAST(b.[Sales_Line_Created_Date] AS DATE) = bd.[Calendar_Date]
			INNER JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON b.Sales_Line_Product_Key = p.Product_Key
			LEFT JOIN [CWC_DW].[Fact].[Purchase_Orders] (NOLOCK) po ON p.Earliest_Open_Purchase_Order_Key = po.Purchase_Order_Key
		WHERE sd.Current_Backorder_Date = 'Current Backorder Date'
		--AND Item_ID = '11729'
		--AND b.is_Removed_From_Source = 0 AND p.Item_ID = '14628' AND Color_Name = 'Currant' AND Size_Name = 'XL'
		GROUP BY b.Sales_Line_Product_Key,CAST(CAST(sd.Fiscal_Year AS VARCHAR(4)) + CAST(CAST(sd.Fiscal_Week_of_Year AS INT) + 100 AS VARCHAR(3)) AS INT),'Wk ' +   CAST(sd.[Fiscal_Week_of_Year] AS VARCHAR(4)) + ' (' + CAST(sd.[Fiscal_Year] AS VARCHAR(4)) + ')'
	) 

INSERT INTO #Backorders_by_SKU

SELECT
	 Product_Key
	,Fiscal_Week_Year_Index
	,Fiscal_Week_Year
	,Backorder_Amount
	,Backorder_Quantity
	,Backorder_Average_Unit_Retail
	,is_Show_Relief
FROM Backorders_By_SKU;

--Populate PO temp table
WITH Backorders_By_SKU AS
	(
		SELECT
			 Product_Key
			,Fiscal_Week_Year_Index
			,Fiscal_Week_Year
			,Backorder_Amount
			,Backorder_Quantity
			,Backorder_Average_Unit_Retail
			,is_Show_Relief
		FROM #Backorders_by_SKU
	) 
--,Vendor_Packing_Slips_By_PO AS
--	(
--		SELECT Purchase_Order_Key
--			  ,Received_Quantity = SUM(CAST(ISNULL([Vendor_Packing_Slip_Quantity],0) AS INT))
--		FROM [CWC_DW].[Fact].[Vendor_Packing_Slips] (NOLOCK) vps
--		WHERE vps.is_Removed_From_Source = 0
--		GROUP BY Purchase_Order_Key
--	)
,Purchase_Order_By_Item AS
	(
		SELECT
			 p.Product_Key
			--,cd.Fiscal_Week_of_Year
			--,cd.Fiscal_Year
			
			,Fiscal_Week_Year_Index = CAST(CAST(cd.Fiscal_Year AS VARCHAR(4)) + CAST(CAST(cd.Fiscal_Week_of_Year AS INT) + 100 AS VARCHAR(3)) AS INT)
			,Fiscal_Week_Year = 'Wk ' +   CAST(cd.[Fiscal_Week_of_Year] AS VARCHAR(3)) + ' (' + CAST(cd.[Fiscal_Year] AS VARCHAR(4)) + ')'
			--,Confirmed_Date_Key = cd.Date_Key
			,Ordered_Quantity = SUM(po.Purchase_Line_Ordered_Quantity)
			,Received_Quantity = SUM(po.Received_Quantity)
			,[Open_Quantity] = SUM(po.Open_Quantity)
			--,Confirmed_Delivery_Date_Max = MAX(po.Purchase_Line_Confirmed_Delivery_Date)
		FROM Backorders_By_SKU bo
			INNER JOIN [CWC_DW].[Fact].[Purchase_Orders] (NOLOCK) po ON bo.Product_Key = po.Product_Key
			INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Purchase_Order_Properties] (NOLOCK) pop ON po.Purchase_Order_Property_Key = pop.Purchase_Order_Property_Key
			LEFT JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] ad ON po.Purchase_Order_Header_Accounting_Date = ad.Calendar_Date
			INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Dates] cd ON po.[Purchase_Line_Confirmed_Delivery_Date] = cd.Calendar_Date
			--LEFT JOIN Vendor_Packing_Slips_By_PO vps ON po.[Purchase_Order_Key] = vps.[Purchase_Order_Key]
			LEFT JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON po.Product_Key = p.Product_Key
			INNER JOIN [CWC_DW].[Dimension].[Purchase_Order_Fill] (NOLOCK) pof ON po.Purchase_Order_Fill_Key = pof.Purchase_Order_Fill_Key
		WHERE   po.Purchase_Order_Header_Accounting_Date >= '8/15/2020' 
			AND po.Purchase_Line_Confirmed_Delivery_Date >= CAST(GETDATE() AS DATE)
			--AND cd.Fiscal_Week_Status IN ('Current Fiscal Week','Future Fiscal Week')
			AND pop.Purchase_Order_Header_Status IN ('Open','Received')
			AND pop.Purchase_Order_Line_Status IN ('Open','Received')
			AND pof.Purchase_Order_Fill_Status = 'Active'
			AND pof.Purchase_Order_Line_Fill_Status = 'Active'
			AND po.is_Removed_From_Source = 0
			--AND p.is_Currently_Backordered = 1
		GROUP BY p.Product_Key		    
				,CAST(CAST(cd.Fiscal_Year AS VARCHAR(4)) + CAST(CAST(cd.Fiscal_Week_of_Year AS INT) + 100 AS VARCHAR(3)) AS INT)
				,'Wk ' +   CAST(cd.[Fiscal_Week_of_Year] AS VARCHAR(3)) + ' (' + CAST(cd.[Fiscal_Year] AS VARCHAR(4)) + ')'
	) --SELECT * FROM Purchase_Order_By_Item

INSERT INTO #PO_Open

SELECT
	 [Product_Key]
	,[Fiscal_Week_Year_Index]
	,[Fiscal_Week_Year]
	,[Ordered_Quantity]
	,[Received_Quantity]
	,[Open_Quantity]
FROM Purchase_Order_By_Item
WHERE [Open_Quantity] > 1;


--UPDATE bo
--SET is_Show_Relief = CASE WHEN po.Product_Key IS NULL THEN 0 ELSE 1 END
--FROM #Backorders_by_SKU (NOLOCK) bo
--LEFT JOIN #PO_Open (NOLOCK) po ON bo.Product_Key = po.Product_Key AND bo.Date_Key = po.Confirmed_Date_Key;


--Declare and assign loop variables
DECLARE 
 @Start_Fiscal_Week_Year_Index INT
,@Stop_Fiscal_Week_Year_Index INT
,@Current_Fiscal_Week_Year_Index INT
,@Current_Fiscal_Week_Year VARCHAR(20)
,@Next_Fiscal_Week_Year_Index INT
,@Next_Fiscal_Week_Year VARCHAR(20);

SELECT  @Current_Fiscal_Week_Year_Index =
	(SELECT MIN(Fiscal_Week_Year_Index) FROM #PO_Open (NOLOCK));

SELECT  @Current_Fiscal_Week_Year =
	(SELECT TOP 1 Fiscal_Week_Year FROM #PO_Open (NOLOCK) WHERE Fiscal_Week_Year_Index = @Current_Fiscal_Week_Year_Index);

SELECT @Start_Fiscal_Week_Year_Index = @Current_Fiscal_Week_Year_Index;

--SELECT @Next_Fiscal_Week_Year_Index = @Current_Fiscal_Week_Year_Index;

SELECT @Stop_Fiscal_Week_Year_Index = (SELECT MAX(Fiscal_Week_Year_Index) FROM #PO_Open (NOLOCK));

TRUNCATE TABLE CWC_DW.Fact.Backorder_Relief_Summary;

WHILE @Current_Fiscal_Week_Year_Index BETWEEN @Start_Fiscal_Week_Year_Index AND @Stop_Fiscal_Week_Year_Index
	BEGIN

		UPDATE #Backorders_by_SKU
		SET [Fiscal_Week_Year_Index] = @Current_Fiscal_Week_Year_Index;

		UPDATE bo
		SET is_Show_Relief = CASE WHEN po.Product_Key IS NULL THEN 0 ELSE 1 END
		FROM #Backorders_by_SKU (NOLOCK) bo
		LEFT JOIN #PO_Open (NOLOCK) po ON bo.Product_Key = po.Product_Key AND @Current_Fiscal_Week_Year_Index = po.Fiscal_Week_Year_Index
		;
		
		INSERT INTO CWC_DW.Fact.Backorder_Relief_Summary

	
				SELECT
					 bo.Product_Key
					,@Current_Fiscal_Week_Year_Index
					,@Current_Fiscal_Week_Year
					,bo.Backorder_Amount
					,bo.Backorder_Quantity
					,Backorder_Average_Unit_Retail
					,Backorder_Relief_Quantity = --CASE WHEN is_Show_Relief = 0 THEN NULL ELSE
														CASE WHEN SUM(po.Open_Quantity) > Backorder_Quantity THEN Backorder_Quantity ELSE SUM(po.Open_Quantity) END
												 --END
					,Bakcorder_Releif_Amount =   --CASE WHEN is_Show_Relief = 0 THEN NULL ELSE
																CASE WHEN SUM(po.Open_Quantity) * Backorder_Average_Unit_Retail > Backorder_Amount THEN Backorder_Amount 
																	 ELSE SUM(po.Open_Quantity) * Backorder_Average_Unit_Retail END
											       --END
					,Backorder_Remainder_Quantity = CASE WHEN ISNULL(SUM(po.Open_Quantity),0) >= Backorder_Quantity THEN 0 ELSE Backorder_Quantity - ISNULL(SUM(po.Open_Quantity),0) END
					,Backorder_Remainder_Amount = CASE WHEN (ISNULL(SUM(po.Open_Quantity),0) * Backorder_Average_Unit_Retail) >= Backorder_Amount THEN 0
													ELSE Backorder_Amount - (ISNULL(SUM(po.Open_Quantity),0) * Backorder_Average_Unit_Retail) END
				    ,is_Show_Relief = ISNULL(is_Show_Relief,0)
				--INTO CWC_DW.Fact.Backorder_Releif_Summary
				FROM #Backorders_by_SKU (NOLOCK) bo
				LEFT JOIN #PO_Open (NOLOCK) po ON bo.Product_Key = po.Product_Key AND bo.Fiscal_Week_Year_Index >= po.Fiscal_Week_Year_Index
				GROUP BY
					 bo.Product_Key
					,bo.Fiscal_Week_Year_Index
					,bo.Fiscal_Week_Year
					,Backorder_Amount
					,Backorder_Quantity
					,Backorder_Average_Unit_Retail
					,is_Show_Relief
					;


		SELECT 
			@Next_Fiscal_Week_Year_Index = CAST(CAST(d2.Fiscal_Year AS VARCHAR(4)) + CAST(CAST(d2.Fiscal_Week_of_Year AS INT) + 100 AS VARCHAR(3)) AS INT)
		   ,@Next_Fiscal_Week_Year = 'Wk ' +   CAST(d2.[Fiscal_Week_of_Year] AS VARCHAR(3)) + ' (' + CAST(d2.[Fiscal_Year] AS VARCHAR(4)) + ')'
		FROM [CWC_DW].[Dimension].[Dates] (NOLOCK) d1
		INNER JOIN [CWC_DW].[Dimension].[Dates] (NOLOCK) d2 ON DATEADD(DAY,1,d1.Calendar_Date) = d2.Calendar_Date
		WHERE CAST(CAST(d1.Fiscal_Year AS VARCHAR(4)) + CAST(CAST(d1.Fiscal_Week_of_Year AS INT) + 100 AS VARCHAR(3)) AS INT) = @Current_Fiscal_Week_Year_Index;

		SELECT @Current_Fiscal_Week_Year_Index = @Next_Fiscal_Week_Year_Index
		      ,@Current_Fiscal_Week_Year = @Next_Fiscal_Week_Year;
	END;

