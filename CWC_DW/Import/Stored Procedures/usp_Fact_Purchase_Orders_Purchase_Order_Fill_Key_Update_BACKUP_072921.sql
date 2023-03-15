
CREATE PROC [Import].[usp_Fact_Purchase_Orders_Purchase_Order_Fill_Key_Update_BACKUP_072921]
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

	WITH Vendor_Packing_Slips
	AS (
		SELECT [Purchase_Order_Key]
			,[Received_Quantity] = SUM([Vendor_Packing_Slip_Quantity])
		FROM [CWC_DW].[Fact].[Vendor_Packing_Slips]
		GROUP BY Purchase_Order_Key
		)
		,PO_Line_Fill
	AS (
		SELECT po.[Purchase_Order_Key]
			,po.[Purchase_Order_Number]
			,[Received_Quantity] = ISNULL(SUM(vps.Received_Quantity), 0)
			,[Ordered_Quantity] = SUM(po.Purchase_Line_Ordered_Quantity)
			,[Purchase_Order_Line_Fill_CD] = CASE 
				WHEN ISNULL(SUM(vps.Received_Quantity), 0) = 0
					THEN 1 --'No Fill' 
				WHEN ISNULL(SUM(vps.Received_Quantity), 0) > SUM(po.Purchase_Line_Ordered_Quantity)
					THEN 4 --'Over Fill'
				WHEN ISNULL(SUM(vps.Received_Quantity), 0) = SUM(po.Purchase_Line_Ordered_Quantity)
					THEN 3 --'Complete Fill'
				WHEN ISNULL(SUM(vps.Received_Quantity), 0) < SUM(po.Purchase_Line_Ordered_Quantity)
					THEN 2 --'Partial Fill'
				END
		FROM [CWC_DW].[Fact].[Purchase_Orders] po
		LEFT JOIN [Vendor_Packing_Slips] vps ON po.[Purchase_Order_Key] = vps.[Purchase_Order_Key]
		GROUP BY po.[Purchase_Order_Key]
			,po.Purchase_Order_Number
		)
		,PO_Fill_Counts
	AS (
		SELECT po.Purchase_Order_Number
			,No_Fill_Count = SUM(CASE [Purchase_Order_Line_Fill_CD]
					WHEN 1
						THEN 1
					ELSE 0
					END)
			,Partial_Fill_Count = SUM(CASE [Purchase_Order_Line_Fill_CD]
					WHEN 2
						THEN 1
					ELSE 0
					END)
			,Complete_Fill_Count = SUM(CASE [Purchase_Order_Line_Fill_CD]
					WHEN 3
						THEN 1
					ELSE 0
					END)
			,Over_Fill_Count = SUM(CASE [Purchase_Order_Line_Fill_CD]
					WHEN 4
						THEN 1
					ELSE 0
					END)
		FROM [CWC_DW].[Fact].[Purchase_Orders] po
		INNER JOIN PO_Line_Fill plf ON po.Purchase_Order_Key = plf.[Purchase_Order_Key]
		GROUP BY po.Purchase_Order_Number
		)
		,PO_Fill
	AS (
		SELECT Purchase_Order_Number
			,[Purchase_Order_Fill_CD] = CASE 
				WHEN No_Fill_Count >= 0
					AND Partial_Fill_Count > 0
					AND Complete_Fill_Count >= 0
					AND Over_Fill_Count >= 0
					THEN 2 --'Partial Fill'
				WHEN No_Fill_Count > 0
					AND Complete_Fill_Count > 0
					THEN 2 --Partial Fill
				WHEN No_Fill_Count > 0
					AND Over_Fill_Count > 0
					THEN 2 --Partial Fill
				WHEN No_Fill_Count = 0
					AND Partial_Fill_Count = 0
					AND Complete_Fill_Count > 0
					AND Over_Fill_Count = 0
					THEN 3 --'Complete Fill'
				WHEN No_Fill_Count > 0
					AND Complete_Fill_Count = 0
					AND Over_Fill_Count = 0
					THEN 1 --No Fill
				WHEN No_Fill_Count = 0
					AND Complete_Fill_Count = 0
					AND Over_Fill_Count > 0
					THEN 4 --'Over Fill'
				WHEN No_Fill_Count = 0
					AND Complete_Fill_Count > 0
					AND Over_Fill_Count > 0
					THEN 4 --'Over Fill'
				END
		FROM PO_Fill_Counts
		)
		,Purchase_Order_Fill
	AS (
		SELECT plf.Purchase_Order_Key
			,pof.Purchase_Order_Fill_Key
			,plf.Purchase_Order_Number
			,plf.[Purchase_Order_Line_Fill_CD]
			,pf.[Purchase_Order_Fill_CD]
		FROM PO_Fill pf
		INNER JOIN PO_Line_Fill plf ON pf.Purchase_Order_Number = plf.Purchase_Order_Number
		LEFT JOIN [CWC_DW].[Dimension].[Purchase_Order_Fill] pof ON pf.Purchase_Order_Fill_CD = pof.Purchase_Order_Fill_CD
			AND plf.Purchase_Order_Line_Fill_CD = pof.Purchase_Order_Line_Fill_CD
		)
	UPDATE po
	SET Purchase_Order_Fill_Key = pof.Purchase_Order_Fill_Key
	FROM Purchase_Order_Fill pof
	INNER JOIN [CWC_DW].[Fact].[Purchase_Orders] po ON pof.Purchase_Order_Key = po.Purchase_Order_Key
	WHERE ISNULL(po.Purchase_Order_Fill_Key, 0) <> ISNULL(pof.Purchase_Order_Fill_Key, 0);

	UPDATE Administration.Procedure_Updates
	SET [Status] = 'SUCCESS'
		,Affected_Rows = @@ROWCOUNT
		,End_Date = getdate()
	WHERE Procedure_Update_Key = @procedureUpdateKey_
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
