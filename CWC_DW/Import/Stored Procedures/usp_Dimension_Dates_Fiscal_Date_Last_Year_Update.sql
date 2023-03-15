
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE PROC [Import].[usp_Dimension_Dates_Fiscal_Date_Last_Year_Update]
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY
	DECLARE @procedureUpdateKey_ AS INT = 0
		,@USER AS VARCHAR(20) = current_user
		,@date AS SMALLDATETIME = getdate()
		,@stored_procedure_name VARCHAR(50) = OBJECT_NAME(@@PROCID);

	EXEC Administration.usp_Procedure_Updates_Insert @procedureName = @stored_procedure_name
		,@procedureUpdateKey = @procedureUpdateKey_ OUTPUT;

	WITH src
	AS (
		SELECT --TOP (1000) 
			[Date_Key]
			,Fiscal_Date_Last_Year = fco.[PRIOR YEAR]
		FROM [CWC_DW].[Dimension].[Dates] d
		INNER JOIN [Import].[FISCAL_CALENDAR_OFFSETS] fco ON d.Calendar_Date = fco.FDATE
		
		UNION
		
		SELECT --TOP (1000) 
			[Date_Key]
			,[PRIOR YEAR] = fco.LLY
		FROM [CWC_DW].[Dimension].[Dates] d
		INNER JOIN [Import].[FISCAL_CALENDAR_OFFSETS] fco ON d.Calendar_Date = fco.[PRIOR YEAR]
		)
	UPDATE d
	SET d.Fiscal_Date_Last_Year = src.Fiscal_Date_Last_Year
	FROM Dimension.Dates d
	INNER JOIN src ON d.Date_Key = src.Date_Key
	WHERE ISNULL(d.[Fiscal_Date_Last_Year], '') <> ISNULL(src.[Fiscal_Date_Last_Year], '');

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