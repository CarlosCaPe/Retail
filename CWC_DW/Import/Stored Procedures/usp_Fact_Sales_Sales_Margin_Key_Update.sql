
CREATE PROC [Import].[usp_Fact_Sales_Sales_Margin_Key_Update]
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

	UPDATE s
	SET Sales_Margin_Key = CASE 
			WHEN (s.Sales_Margin_Rate * 100) <= 0
				THEN 1
			WHEN (s.Sales_Margin_Rate * 100) > 0
				AND (s.Sales_Margin_Rate * 100) <= 10
				THEN 2
			WHEN (s.Sales_Margin_Rate * 100) > 10
				AND (s.Sales_Margin_Rate * 100) <= 20
				THEN 3
			WHEN (s.Sales_Margin_Rate * 100) > 20
				AND (s.Sales_Margin_Rate * 100) <= 30
				THEN 4
			WHEN (s.Sales_Margin_Rate * 100) > 30
				AND (s.Sales_Margin_Rate * 100) <= 40
				THEN 5
			WHEN (s.Sales_Margin_Rate * 100) > 40
				AND (s.Sales_Margin_Rate * 100) <= 50
				THEN 6
			WHEN (s.Sales_Margin_Rate * 100) > 50
				AND (s.Sales_Margin_Rate * 100) <= 60
				THEN 7
			WHEN (s.Sales_Margin_Rate * 100) > 60
				AND (s.Sales_Margin_Rate * 100) <= 70
				THEN 8
			WHEN (s.Sales_Margin_Rate * 100) > 70
				AND (s.Sales_Margin_Rate * 100) <= 80
				THEN 9
			WHEN (s.Sales_Margin_Rate * 100) > 80
				AND (s.Sales_Margin_Rate * 100) <= 90
				THEN 10
			WHEN (s.Sales_Margin_Rate * 100) > 90
				THEN 11
			END
	FROM [CWC_DW].[Fact].[Sales] s
	WHERE ISNULL(s.Sales_Margin_Key, 0) <> CASE 
			WHEN (s.Sales_Margin_Rate * 100) <= 0
				THEN 1
			WHEN (s.Sales_Margin_Rate * 100) > 0
				AND (s.Sales_Margin_Rate * 100) <= 10
				THEN 2
			WHEN (s.Sales_Margin_Rate * 100) > 10
				AND (s.Sales_Margin_Rate * 100) <= 20
				THEN 3
			WHEN (s.Sales_Margin_Rate * 100) > 20
				AND (s.Sales_Margin_Rate * 100) <= 30
				THEN 4
			WHEN (s.Sales_Margin_Rate * 100) > 30
				AND (s.Sales_Margin_Rate * 100) <= 40
				THEN 5
			WHEN (s.Sales_Margin_Rate * 100) > 40
				AND (s.Sales_Margin_Rate * 100) <= 50
				THEN 6
			WHEN (s.Sales_Margin_Rate * 100) > 50
				AND (s.Sales_Margin_Rate * 100) <= 60
				THEN 7
			WHEN (s.Sales_Margin_Rate * 100) > 60
				AND (s.Sales_Margin_Rate * 100) <= 70
				THEN 8
			WHEN (s.Sales_Margin_Rate * 100) > 70
				AND (s.Sales_Margin_Rate * 100) <= 80
				THEN 9
			WHEN (s.Sales_Margin_Rate * 100) > 80
				AND (s.Sales_Margin_Rate * 100) <= 90
				THEN 10
			WHEN (s.Sales_Margin_Rate * 100) > 90
				THEN 11
			END;

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


