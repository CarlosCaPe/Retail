
CREATE PROC [Import].[usp_Fact_Sales_Sales_Line_Created_Date_EST_Update]
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

	WITH Sales_Date
	AS (
		SELECT Sales_Key
			,Sales_Line_Created_Date_EST = DATEADD(hh, (
					SELECT cast(replace(current_utc_offset, ':00', '') AS INT)
					FROM [sys].[time_zone_info] tz
					WHERE tz.name = 'US Eastern Standard Time'
					), s.[Sales_Line_Created_Date])
		FROM CWC_DW.Fact.Sales s
		)
	UPDATE s
	SET Sales_Line_Created_Date_EST = sd.Sales_Line_Created_Date_EST
	FROM CWC_DW.Fact.Sales s
	INNER JOIN Sales_Date sd ON s.Sales_Key = sd.Sales_Key
	WHERE ISNULL(s.Sales_Line_Created_Date_EST, '') <> ISNULL(sd.Sales_Line_Created_Date_EST, '');

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

