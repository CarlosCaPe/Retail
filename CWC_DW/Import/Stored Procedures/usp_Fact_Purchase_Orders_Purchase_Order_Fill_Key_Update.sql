﻿

CREATE PROC [Import].[usp_Fact_Purchase_Orders_Purchase_Order_Fill_Key_Update] AS

WITH Vendor_Packing_Slips AS
	(
		SELECT [Purchase_Order_Key]
			  ,[Received_Quantity] = SUM([Vendor_Packing_Slip_Quantity])
		FROM [CWC_DW].[Fact].[Vendor_Packing_Slips] (NOLOCK)
		GROUP BY Purchase_Order_Key
	)
,PO_Line_Fill AS
(
  SELECT po.[Purchase_Order_Key]
		,po.[Purchase_Order_Number]
      --,[Received_Quantity] = SUM(vps.Received_Quantity)
	  --,[Purchase_Line_Ordered_Quantity] = SUM(po.Purchase_Line_Ordered_Quantity)
	  ,[Received_Quantity] = ISNULL(SUM(vps.Received_Quantity),0)
	  ,[Ordered_Quantity] = SUM(po.Purchase_Line_Ordered_Quantity)
	  ,[Purchase_Order_Line_Fill_CD] = CASE WHEN ISNULL(SUM(vps.Received_Quantity),0) = 0 THEN 1 --'No Fill' 
									   WHEN ISNULL(SUM(vps.Received_Quantity),0) > SUM(po.Purchase_Line_Ordered_Quantity) THEN 4 --'Over Fill'
									   WHEN ISNULL(SUM(vps.Received_Quantity),0) = SUM(po.Purchase_Line_Ordered_Quantity) THEN 3 --'Complete Fill'
									   WHEN ISNULL(SUM(vps.Received_Quantity),0) < SUM(po.Purchase_Line_Ordered_Quantity) THEN 2 --'Partial Fill'
								   END
  FROM [CWC_DW].[Fact].[Purchase_Orders] (NOLOCK) po
  LEFT JOIN [Vendor_Packing_Slips] vps ON po.[Purchase_Order_Key] = vps.[Purchase_Order_Key]
  --WHERE po.[Purchase_Order_Number] = '18472'
  GROUP BY po.[Purchase_Order_Key],po.Purchase_Order_Number
)--SELECT * FROM PO_Line_Fill
,PO_Fill_Counts AS
	(
		SELECT 
			 po.Purchase_Order_Number
			,No_Fill_Count = SUM(CASE WHEN [Purchase_Order_Line_Fill_CD] = 1 AND pop.Purchase_Order_Line_Status <> 'Canceled' THEN 1 ELSE 0 END)
			,Partial_Fill_Count= SUM(CASE WHEN [Purchase_Order_Line_Fill_CD] = 2 AND pop.Purchase_Order_Line_Status <> 'Canceled' THEN 1 ELSE 0 END)
			,Complete_Fill_Count = SUM((CASE WHEN [Purchase_Order_Line_Fill_CD] = 3 AND pop.Purchase_Order_Line_Status <> 'Canceled' THEN 1 ELSE 0 END))
			,Over_Fill_Count = SUM((CASE WHEN [Purchase_Order_Line_Fill_CD] = 4 AND pop.Purchase_Order_Line_Status <> 'Canceled' THEN 1 ELSE 0 END))
		FROM [CWC_DW].[Fact].[Purchase_Orders] (NOLOCK) po
		INNER JOIN PO_Line_Fill plf ON po.Purchase_Order_Key = plf.[Purchase_Order_Key]
		INNER JOIN [CWC_DW].[Power_BI].[v_Dim_Purchase_Order_Properties] (NOLOCK) pop ON po.Purchase_Order_Property_Key = pop.Purchase_Order_Property_Key
		--WHERE pop.Purchase_Order_Line_Status <> 'Canceled'
		GROUP BY po.Purchase_Order_Number
	) --SELECT * FROM PO_Fill_Counts 
,PO_Fill AS
	(
		SELECT
		 Purchase_Order_Number

		,[Purchase_Order_Fill_CD] = 
									CASE
										WHEN No_Fill_Count >= 0 AND Partial_Fill_Count > 0 AND Complete_Fill_Count >= 0 AND Over_Fill_Count >= 0 THEN 2 --'Partial Fill'
										WHEN No_Fill_Count > 0 AND Complete_Fill_Count > 0 THEN 2 --Partial Fill
										WHEN No_Fill_Count > 0 AND Over_Fill_Count > 0  THEN 2 --Partial Fill

										WHEN No_Fill_Count = 0 AND Partial_Fill_Count = 0 AND Complete_Fill_Count > 0 AND Over_Fill_Count = 0 THEN 3 --'Complete Fill'

										WHEN No_Fill_Count > 0 AND Complete_Fill_Count = 0 AND Over_Fill_Count = 0 THEN 1 --No Fill

										WHEN No_Fill_Count = 0 AND Complete_Fill_Count = 0 AND Over_Fill_Count > 0 THEN 4 --'Over Fill'
										WHEN No_Fill_Count = 0 AND Complete_Fill_Count > 0 AND Over_Fill_Count > 0 THEN 4 --'Over Fill'

										WHEN No_Fill_Count = 0 AND Partial_Fill_Count = 0 AND Complete_Fill_Count = 0 AND Over_Fill_Count = 0 THEN 5 --'Invalid'
									END
		FROM PO_Fill_Counts
	) --SELECT * FROM PO_Fill --WHERE Purchase_Order_Fill_CD = 5
,Purchase_Order_Fill AS
	(
		SELECT 
			 plf.Purchase_Order_Key
			,pof.Purchase_Order_Fill_Key
			,plf.Purchase_Order_Number
			,plf.[Purchase_Order_Line_Fill_CD]
			,pf.[Purchase_Order_Fill_CD]
		FROM PO_Fill pf
			INNER JOIN PO_Line_Fill plf ON pf.Purchase_Order_Number = plf.Purchase_Order_Number
			LEFT JOIN [CWC_DW].[Dimension].[Purchase_Order_Fill] (NOLOCK) pof ON pf.Purchase_Order_Fill_CD = pof.Purchase_Order_Fill_CD AND plf.Purchase_Order_Line_Fill_CD = pof.Purchase_Order_Line_Fill_CD
	) 

--SELECT * 
--FROM Purchase_Order_Fill pof
--RIGHT JOIN [CWC_DW].[Fact].[Purchase_Orders] (NOLOCK) po ON pof.Purchase_Order_Key = po.Purchase_Order_Key
--WHERE pof.Purchase_Order_Fill_Key IS NULL

UPDATE po
SET Purchase_Order_Fill_Key = pof.Purchase_Order_Fill_Key
FROM Purchase_Order_Fill pof
	INNER JOIN [CWC_DW].[Fact].[Purchase_Orders] (NOLOCK) po ON pof.Purchase_Order_Key = po.Purchase_Order_Key
WHERE ISNULL(po.Purchase_Order_Fill_Key,0) <> ISNULL(pof.Purchase_Order_Fill_Key,0);