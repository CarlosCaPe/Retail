
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE PROC [Import].[usp_Fact_Sessions_Merge]
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

BEGIN TRY
	DECLARE @procedureUpdateKey_ AS INT = 0
		,@USER AS VARCHAR(20) = current_user
		,@date AS SMALLDATETIME = getdate()
		,@stored_procedure_name VARCHAR(50) = OBJECT_NAME(@@PROCID);

	EXEC Administration.usp_Procedure_Updates_Insert @procedureName = @stored_procedure_name
		,@procedureUpdateKey = @procedureUpdateKey_ OUTPUT;;

	WITH src
	AS (
		SELECT [Date_Key] = d.[Date_Key]
			,[Date] = CAST([Date] AS DATE)
			,[Sessions] = SUM([Sessions])
			,[Transactions] = SUM([Transactions])
			,[Revenue] = SUM([Revenue])
			,[is_Removed_From_Source] = CAST(0 AS BIT)
			,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Count] = CAST(1 AS TINYINT)
		FROM [CWC_DW].[Import].[GA_ACQUISITION_301] ga
		INNER JOIN [CWC_DW].[Dimension].[Dates] d ON CAST([Date] AS DATE) = d.Calendar_Date
		GROUP BY d.[Date_Key]
			,CAST([Date] AS DATE)
		)
		,tgt
	AS (
		SELECT *
		FROM [CWC_DW].[Fact].[Sessions]
		)
	MERGE INTO tgt
	USING src
		ON tgt.[Date_Key] = src.[Date_Key]
	WHEN NOT MATCHED
		THEN
			INSERT (
				[Date_Key]
				,[Date]
				,[Sessions]
				,[Transactions]
				,[Revenue]
				,[is_Removed_From_Source]
				,[ETL_Created_Date]
				,[ETL_Modified_Date]
				,[ETL_Modified_Count]
				)
			VALUES (
				src.[Date_Key]
				,src.[Date]
				,src.[Sessions]
				,src.[Transactions]
				,src.[Revenue]
				,src.[is_Removed_From_Source]
				,src.[ETL_Created_Date]
				,src.[ETL_Modified_Date]
				,src.[ETL_Modified_Count]
				)
	WHEN MATCHED
		AND ISNULL(tgt.[Date], '') <> ISNULL(src.[Date], '')
		OR ISNULL(tgt.[Sessions], '') <> ISNULL(src.[Sessions], '')
		OR ISNULL(tgt.[Transactions], '') <> ISNULL(src.[Transactions], '')
		OR ISNULL(tgt.[Revenue], '') <> ISNULL(src.[Revenue], '')
		OR ISNULL(tgt.[is_Removed_From_Source], '') <> ISNULL(src.[is_Removed_From_Source], '')
		THEN
			UPDATE
			SET [Date] = src.[Date]
				,[Sessions] = src.[Sessions]
				,[Transactions] = src.[Transactions]
				,[Revenue] = src.[Revenue]
				,[is_Removed_From_Source] = src.[is_Removed_From_Source]
				,[ETL_Modified_Date] = src.[ETL_Modified_Date]
				,[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count], 1) + 1)
	WHEN NOT MATCHED BY SOURCE
		AND tgt.[is_Removed_From_Source] <> 1
		THEN
			UPDATE
			SET tgt.[is_Removed_From_Source] = 1
				,tgt.[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
				,tgt.[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count], 1) + 1);

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
			