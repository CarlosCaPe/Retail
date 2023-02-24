﻿CREATE PROC [Import].[usp_Fact_Demand_Summary_Merge]

AS

SET NOCOUNT ON;

DECLARE @Start_Date INT, @Stop_Date INT;

SELECT 
 @Start_Date = MIN(Date_Key)
,@Stop_Date = MAX(Date_Key)
FROM CWC_DW.Dimension.Dates
WHERE Calendar_Date BETWEEN CAST(GETDATE()-380 AS DATE) AND CAST(GETDATE()-1 AS DATE);

--SELECT @Start_Date,@Stop_Date;

WITH BO_Seq AS
	(
		SELECT
			 Snapshot_Date_Key
			,Sales_Key
			,Seq = ROW_NUMBER()OVER(PARTITION BY Sales_Key ORDER BY Snapshot_Date_Key)
		FROM [CWC_DW].[Fact].[Backorders] (NOLOCK) b 
	) --SELECT TOP 1000 * FROM BO_Seq
,BO AS
	(
		SELECT
			 d.Date_Key
			--,Backorder_Amount = SUM(b.Sales_Line_Amount)
			--,[Demand] = SUM(s.Sales_Line_Amount)
			--,[Units] = SUM(s.Sales_Line_Ordered_Quantity)
			--,[Orders] = COUNT(DISTINCT s.Sales_Order_Number)
			,Amount_Backorder = SUM(([Sales_Line_Amount]/CAST([Sales_Line_Ordered_Sales_Quantity] AS NUMERIC(18,6))) * CAST([Sales_Line_Remain_Sales_Physical] AS NUMERIC(18,6)))
			,Units_Backorder = SUM(b.[Sales_Line_Remain_Sales_Physical])
			,Orders_Backorder = COUNT(DISTINCT b.Sales_Order_Number)
		FROM [CWC_DW].[Dimension].[Dates] (NOLOCK) d
		INNER JOIN [CWC_DW].[Fact].[Backorders] (NOLOCK) b ON d.Date_Key = b.Snapshot_Date_Key --AND CAST(b.[Sales_Line_Created_Date] AS DATE) = d.Calendar_Date
		INNER JOIN BO_Seq bo ON bo.Snapshot_Date_Key = b.Snapshot_Date_Key AND bo.Sales_Key = b.Sales_Key AND bo.Seq = 1
		WHERE d.[Date_Key] BETWEEN @Start_Date AND @Stop_Date --AND b.Snapshot_Date_Key = 20220921
		GROUP BY d.[Date_Key]
	) --SELECT * FROM BO
,Demand AS
	(
		SELECT
			 d.Date_Key
			--,Backorder_Amount = SUM(b.Sales_Line_Amount)
			,[Demand] = SUM(s.Sales_Line_Amount)
			,[Units] = SUM(s.Sales_Line_Ordered_Quantity)
			,[Orders] = COUNT(DISTINCT s.Sales_Order_Number)
			,[Amount_Canceled] = SUM(CASE WHEN Order_Classification = 'Canceled Sale' THEN s.Sales_Line_Amount ELSE NULL END)
			,[Units_Canceled] = SUM(CASE WHEN Order_Classification = 'Canceled Sale' THEN s.Sales_Line_Ordered_Quantity ELSE NULL END)
		FROM CWC_DW.Dimension.Dates d
		INNER JOIN [CWC_DW].[Power_BI].[v_Fact_Sales_Sales_With_Cancels] s ON d.Calendar_Date = CAST(s.Sales_Header_Created_Date AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' AS DATE)
		--INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes] soa ON s.[Sales_Order_Attribute_Key = soa.Sales_Order_Attribute_Key
		WHERE d.[Date_Key] BETWEEN @Start_Date AND @Stop_Date
		GROUP BY d.[Date_Key]
	)
,Backorder_Shipped AS
	(
		SELECT
		  d.[Date_Key]
		  ,[Backorder_Shipped_Amount] = SUM(i.[Invoice_Line_Amount])
		  ,[Backorder_Shipped_Quantity] = SUM(i.[Invoice_Line_Quantity])
		FROM CWC_DW.Dimension.Dates (NOLOCK) d 
		INNER JOIN [CWC_DW].[Fact].[Invoices] (NOLOCK) i ON i.Invoice_Line_Date_Key = d.Date_Key
		INNER JOIN [CWC_DW].[Dimension].[Invoice_Attributes] (NOLOCK) ia ON i.Invoice_Attribute_Key = ia.Invoice_Attribute_Key
		WHERE ia.is_Backorder_Fill = 1 AND LEFT(Invoice_Number,3) = 'INV' --AND d.Fiscal_Week_Name = 'Aug 2021 (Wk 31)'
		AND d.[Date_Key] BETWEEN @Start_Date AND @Stop_Date
		GROUP BY d.Date_Key
		--ORDER BY SUM(i.[Invoice_Line_Amount])
	)
,BO_Cancel AS 
	(
		SELECT 
			 [Date_Key]
			,[Backorder_Canceled_Amount] = SUM(s.Sales_Line_Amount)
			,[Backorder_Canceled_Quantity] = SUM(s.Sales_Line_Ordered_Quantity)
		FROM CWC_DW.Dimension.Dates (NOLOCK) d 
		INNER JOIN [CWC_DW].[Power_BI].[v_Fact_Sales_Sales_With_Cancels] s ON d.Calendar_Date = CAST(s.[Sales_Line_Created_Date] AS DATE)
		--INNER JOIN [CWC_DW].[Dimension].[Sales_Order_Attributes] soa ON s.Sales_Order_Attribute_Key = soa.Sales_Order_Attribute_Key
		WHERE  EXISTS
		(
			SELECT DISTINCT b.[Sales_Key]
			FROM [CWC_DW].[Fact].[Backorders] b
				INNER JOIN [CWC_DW].[Dimension].[Dates] d ON b.[Snapshot_Date_Key] = d.[Date_Key]
			WHERE s.[Sales_Key] = b.Sales_Key --AND d.[Fiscal_Year] = 2022 AND d.[Week_of_Year] = 14
		)
		AND Order_Classification = 'Canceled Sale'
		AND d.[Date_Key] BETWEEN @Start_Date AND @Stop_Date
		GROUP BY Date_Key
	) 
,src AS
	(
		SELECT
			 d.[Date_Key]
			,[Demand]
			,[Units]
			,[Orders]
			,[Amount_Canceled]
			,[Units_Canceled]
			,[Amount_Backorder]
			,[Units_Backorder]
			,[Orders_Backorder]
			,[Backorder_Shipped_Amount]
			,[Backorder_Shipped_Quantity]
			,[Backorder_Canceled_Amount]
		    ,[Backorder_Canceled_Quantity]
			,[is_Removed_From_Source] = CAST(0 AS BIT)
			,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Count] = CAST(1 AS SMALLINT)
		--INTO CWC_DW.Fact.Demand_Summary
		FROM CWC_DW.Dimension.Dates d
			LEFT JOIN Demand dem ON d.Date_Key = dem.Date_Key 
			LEFT JOIN BO ON d.Date_Key = BO.Date_Key
			LEFT JOIN Backorder_Shipped bs ON d.Date_Key = bs.Date_Key 
			LEFT JOIN BO_Cancel bc ON d.Date_Key = bc.Date_Key
		WHERE d.[Date_Key] BETWEEN @Start_Date AND @Stop_Date
	) --SELECT * FROM src WHERE Date_Key = 20210802
,tgt AS (SELECT * FROM  CWC_DW.Fact.Demand_Summary (NOLOCK) WHERE [Date_Key] BETWEEN @Start_Date AND @Stop_Date)

MERGE INTO tgt USING src
	ON tgt.Date_Key = src.Date_Key
		WHEN NOT MATCHED THEN
			INSERT([Date_Key],[Demand],[Units],[Orders],[Amount_Canceled],[Units_Canceled],[Amount_Backorder],[Units_Backorder],[Orders_Backorder],[Backorder_Shipped_Amount],[Backorder_Shipped_Quantity],[Backorder_Canceled_Amount],[Backorder_Canceled_Quantity]
			     ,[is_Removed_From_Source],[ETL_Created_Date],[ETL_Modified_Date],[ETL_Modified_Count])
			VALUES(src.[Date_Key],src.[Demand],src.[Units],src.[Orders],src.[Amount_Canceled],src.[Units_Canceled],src.[Amount_Backorder],src.[Units_Backorder],src.[Orders_Backorder],src.[Backorder_Shipped_Amount],src.[Backorder_Shipped_Quantity]
			     ,src.[Backorder_Canceled_Amount],src.[Backorder_Canceled_Quantity],src.[is_Removed_From_Source],src.[ETL_Created_Date],src.[ETL_Modified_Date],src.[ETL_Modified_Count])
		WHEN MATCHED AND
			   ISNULL(tgt.[Demand],0) <> ISNULL(src.[Demand],0)
			OR ISNULL(tgt.[Units],0) <> ISNULL(src.[Units],0)
			OR ISNULL(tgt.[Orders],0) <> ISNULL(src.[Orders],0)
			OR ISNULL(tgt.[Amount_Canceled],0) <> ISNULL(src.[Amount_Canceled],0)
			OR ISNULL(tgt.[Units_Canceled],0) <> ISNULL(src.[Units_Canceled],0)
			OR ISNULL(tgt.[Amount_Backorder],0) <> ISNULL(src.[Amount_Backorder],0)
			OR ISNULL(tgt.[Units_Backorder],0) <> ISNULL(src.[Units_Backorder],0)
			OR ISNULL(tgt.[Orders_Backorder],0) <> ISNULL(src.[Orders_Backorder],0)
			OR ISNULL(tgt.[Backorder_Shipped_Amount],0) <> ISNULL(src.[Backorder_Shipped_Amount],0)
			OR ISNULL(tgt.[Backorder_Shipped_Quantity],0) <> ISNULL(src.[Backorder_Shipped_Quantity],0)
			OR ISNULL(tgt.[Backorder_Canceled_Amount],0) <> ISNULL(src.[Backorder_Canceled_Amount],0)
			OR ISNULL(tgt.[Backorder_Canceled_Quantity],0) <> ISNULL(src.[Backorder_Canceled_Quantity],0)
			OR ISNULL(tgt.[is_Removed_From_Source],'') <> ISNULL(src.[is_Removed_From_Source],'')
		THEN UPDATE SET
			 [Demand] = src.[Demand]
			,[Units] = src.[Units]
			,[Orders] = src.[Orders]
			,[Amount_Canceled] = src.[Amount_Canceled]
			,[Units_Canceled] = src.[Units_Canceled]
			,[Amount_Backorder] = src.[Amount_Backorder]
			,[Units_Backorder] = src.[Units_Backorder]
			,[Orders_Backorder] = src.[Orders_Backorder]
			,[Backorder_Shipped_Amount] = src.[Backorder_Shipped_Amount]
			,[Backorder_Shipped_Quantity] = src.[Backorder_Shipped_Quantity]
			,[Backorder_Canceled_Amount] = src.[Backorder_Canceled_Amount]
			,[Backorder_Canceled_Quantity] = src.[Backorder_Canceled_Quantity]
			,[is_Removed_From_Source] = src.[is_Removed_From_Source]
			,[ETL_Modified_Date] = src.[ETL_Modified_Date]
			,[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1)
		WHEN NOT MATCHED BY SOURCE AND tgt.[is_Removed_From_Source] <> 1 THEN UPDATE SET
			tgt.[is_Removed_From_Source] = 1
			,tgt.[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,tgt.[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1);