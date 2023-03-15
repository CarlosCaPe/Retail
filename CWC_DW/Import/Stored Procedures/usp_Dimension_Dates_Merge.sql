
CREATE PROC [Import].[usp_Dimension_Dates_Merge]
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
		SELECT [Date_Key] = REPLACE(CAST(CAST(d.[Calendar_Date] AS [Date]) AS VARCHAR(10)), '-', '')
			,[Calendar_Date]
			,[Calendar_Month]
			,[Calendar_Day]
			,[Calendar_Year]
			,[Calendar_Quarter]
			,[Calendar_Quarter_Name] = 'Q' + CAST([Calendar_Quarter] AS VARCHAR(10))
			,[Calendar_Quarter_Year_Name] = 'Q' + CAST([Calendar_Quarter] AS VARCHAR(10)) + ' ' + CAST([Calendar_Year] AS VARCHAR(10))
			,[Day_Name]
			,[Day_of_Week]
			,[Day_of_Week_in_Month]
			,[Day_of_Week_in_Year]
			,[Day_of_Week_in_Quarter]
			,[Day_of_Quarter]
			,[Day_of_Year]
			,[Week_of_Month]
			,[Week_of_Quarter]
			,[Week_of_Year]
			,[Month_Name]
			,[First_Date_of_Week]
			,[Last_Date_of_Week]
			,[First_Date_of_Month]
			,[Last_Date_of_Month]
			,[First_Date_of_Quarter]
			,[Last_Date_of_Quarter]
			,[First_Date_of_Year]
			,[Last_Date_of_Year]
			,[is_Holiday]
			,[is_Holiday_Season]
			,[Holiday_Name]
			,[Holiday_Season_Name]
			,[is_Weekday]
			,[is_Business_Day]
			,[Previous_Business_Day]
			,[Next_Business_Day]
			,[is_Leap_Year]
			,[Days_in_Month]
			,[Fiscal_Day_of_Year] = [FiscalDayOfYear]
			,[Fiscal_Week_of_Year] = [FiscalWeekOfYear]
			,[Fiscal_Month] = [FiscalMonth]
			,[Fiscal_Quarter] = [FiscalQuarter]
			,[Fiscal_Quarter_Name] = 'Q' + CAST([FiscalQuarter] AS VARCHAR(10))
			,[Fiscal_Quarter_Year_Name] = 'Q' + CAST([FiscalQuarter] AS VARCHAR(10)) + ' ' + CAST([FiscalYear] AS VARCHAR(10))
			,[Fiscal_Year] = [FiscalYear]
			,[Fiscal_Year_Name] = [FiscalYearName]
			,[Fiscal_Month_Year] = [FiscalMonthYear]
			,[Fiscal_MMYYYY] = [FiscalMMYYYY]
			,[Fiscal_First_Day_of_Month] = [FiscalFirstDayOfMonth]
			,[Fiscal_Last_Day_of_Month] = [FiscalLastDayOfMonth]
			,[Fiscal_First_Day_of_Quarter] = [FiscalFirstDayOfQuarter]
			,[Fiscal_Last_Day_of_Quarter] = [FiscalLastDayOfQuarter]
			,[Fiscal_First_Day_of_Year] = [FiscalFirstDayOfYear]
			,[Fiscal_Last_Day_of_Year] = [FiscalLastDayOfYear]
			,[is_Removed_From_Source] = CAST(0 AS BIT)
			,[is_Excluded] = CAST(0 AS BIT)
			,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Count] = CAST(1 AS TINYINT)
		--INTO CWC_DW.Dimension.Dates
		FROM [AX_PRODUCTION_REPORTING].[dbo].[Dim_Date] d
		)
		,tgt
	AS (
		SELECT *
		FROM [CWC_DW].[Dimension].[Dates]
		)
	MERGE INTO tgt
	USING src
		ON tgt.[Date_Key] = src.[Date_Key]
	WHEN NOT MATCHED
		THEN
			INSERT (
				[Date_Key]
				,[Calendar_Date]
				,[Calendar_Month]
				,[Calendar_Day]
				,[Calendar_Year]
				,[Calendar_Quarter]
				,[Calendar_Quarter_Name]
				,[Calendar_Quarter_Year_Name]
				,[Day_Name]
				,[Day_of_Week]
				,[Day_of_Week_in_Month]
				,[Day_of_Week_in_Year]
				,[Day_of_Week_in_Quarter]
				,[Day_of_Quarter]
				,[Day_of_Year]
				,[Week_of_Month]
				,[Week_of_Quarter]
				,[Week_of_Year]
				,[Month_Name]
				,[First_Date_of_Week]
				,[Last_Date_of_Week]
				,[First_Date_of_Month]
				,[Last_Date_of_Month]
				,[First_Date_of_Quarter]
				,[Last_Date_of_Quarter]
				,[First_Date_of_Year]
				,[Last_Date_of_Year]
				,[is_Holiday]
				,[is_Holiday_Season]
				,[Holiday_Name]
				,[Holiday_Season_Name]
				,[is_Weekday]
				,[is_Business_Day]
				,[Previous_Business_Day]
				,[Next_Business_Day]
				,[is_Leap_Year]
				,[Days_in_Month]
				,[Fiscal_Day_of_Year]
				,[Fiscal_Week_of_Year]
				,[Fiscal_Month]
				,[Fiscal_Quarter]
				,[Fiscal_Quarter_Name]
				,[Fiscal_Quarter_Year_Name]
				,[Fiscal_Year]
				,[Fiscal_Year_Name]
				,[Fiscal_Month_Year]
				,[Fiscal_MMYYYY]
				,[Fiscal_First_Day_of_Month]
				,[Fiscal_Last_Day_of_Month]
				,[Fiscal_First_Day_of_Quarter]
				,[Fiscal_Last_Day_of_Quarter]
				,[Fiscal_First_Day_of_Year]
				,[Fiscal_Last_Day_of_Year]
				,[is_Removed_From_Source]
				,[is_Excluded]
				,[ETL_Created_Date]
				,[ETL_Modified_Date]
				,[ETL_Modified_Count]
				)
			VALUES (
				src.[Date_Key]
				,src.[Calendar_Date]
				,src.[Calendar_Month]
				,src.[Calendar_Day]
				,src.[Calendar_Year]
				,src.[Calendar_Quarter]
				,src.[Calendar_Quarter_Name]
				,src.[Calendar_Quarter_Year_Name]
				,src.[Day_Name]
				,src.[Day_of_Week]
				,src.[Day_of_Week_in_Month]
				,src.[Day_of_Week_in_Year]
				,src.[Day_of_Week_in_Quarter]
				,src.[Day_of_Quarter]
				,src.[Day_of_Year]
				,src.[Week_of_Month]
				,src.[Week_of_Quarter]
				,src.[Week_of_Year]
				,src.[Month_Name]
				,src.[First_Date_of_Week]
				,src.[Last_Date_of_Week]
				,src.[First_Date_of_Month]
				,src.[Last_Date_of_Month]
				,src.[First_Date_of_Quarter]
				,src.[Last_Date_of_Quarter]
				,src.[First_Date_of_Year]
				,src.[Last_Date_of_Year]
				,src.[is_Holiday]
				,src.[is_Holiday_Season]
				,src.[Holiday_Name]
				,src.[Holiday_Season_Name]
				,src.[is_Weekday]
				,src.[is_Business_Day]
				,src.[Previous_Business_Day]
				,src.[Next_Business_Day]
				,src.[is_Leap_Year]
				,src.[Days_in_Month]
				,src.[Fiscal_Day_of_Year]
				,src.[Fiscal_Week_of_Year]
				,src.[Fiscal_Month]
				,src.[Fiscal_Quarter]
				,src.[Fiscal_Quarter_Name]
				,src.[Fiscal_Quarter_Year_Name]
				,src.[Fiscal_Year]
				,src.[Fiscal_Year_Name]
				,src.[Fiscal_Month_Year]
				,src.[Fiscal_MMYYYY]
				,src.[Fiscal_First_Day_of_Month]
				,src.[Fiscal_Last_Day_of_Month]
				,src.[Fiscal_First_Day_of_Quarter]
				,src.[Fiscal_Last_Day_of_Quarter]
				,src.[Fiscal_First_Day_of_Year]
				,src.[Fiscal_Last_Day_of_Year]
				,src.[is_Removed_From_Source]
				,src.[is_Excluded]
				,src.[ETL_Created_Date]
				,src.[ETL_Modified_Date]
				,src.[ETL_Modified_Count]
				)
	WHEN MATCHED
		AND ISNULL(tgt.[Calendar_Date], '') <> ISNULL(src.[Calendar_Date], '')
		OR ISNULL(tgt.[Calendar_Month], '') <> ISNULL(src.[Calendar_Month], '')
		OR ISNULL(tgt.[Calendar_Day], '') <> ISNULL(src.[Calendar_Day], '')
		OR ISNULL(tgt.[Calendar_Year], '') <> ISNULL(src.[Calendar_Year], '')
		OR ISNULL(tgt.[Calendar_Quarter], '') <> ISNULL(src.[Calendar_Quarter], '')
		OR ISNULL(tgt.[Calendar_Quarter_Name], '') <> ISNULL(src.[Calendar_Quarter_Name], '')
		OR ISNULL(tgt.[Calendar_Quarter_Year_Name], '') <> ISNULL(src.[Calendar_Quarter_Year_Name], '')
		OR ISNULL(tgt.[Day_Name], '') <> ISNULL(src.[Day_Name], '')
		OR ISNULL(tgt.[Day_of_Week], '') <> ISNULL(src.[Day_of_Week], '')
		OR ISNULL(tgt.[Day_of_Week_in_Month], '') <> ISNULL(src.[Day_of_Week_in_Month], '')
		OR ISNULL(tgt.[Day_of_Week_in_Year], '') <> ISNULL(src.[Day_of_Week_in_Year], '')
		OR ISNULL(tgt.[Day_of_Week_in_Quarter], '') <> ISNULL(src.[Day_of_Week_in_Quarter], '')
		OR ISNULL(tgt.[Day_of_Quarter], '') <> ISNULL(src.[Day_of_Quarter], '')
		OR ISNULL(tgt.[Day_of_Year], '') <> ISNULL(src.[Day_of_Year], '')
		OR ISNULL(tgt.[Week_of_Month], '') <> ISNULL(src.[Week_of_Month], '')
		OR ISNULL(tgt.[Week_of_Quarter], '') <> ISNULL(src.[Week_of_Quarter], '')
		OR ISNULL(tgt.[Week_of_Year], '') <> ISNULL(src.[Week_of_Year], '')
		OR ISNULL(tgt.[Month_Name], '') <> ISNULL(src.[Month_Name], '')
		OR ISNULL(tgt.[First_Date_of_Week], '') <> ISNULL(src.[First_Date_of_Week], '')
		OR ISNULL(tgt.[Last_Date_of_Week], '') <> ISNULL(src.[Last_Date_of_Week], '')
		OR ISNULL(tgt.[First_Date_of_Month], '') <> ISNULL(src.[First_Date_of_Month], '')
		OR ISNULL(tgt.[Last_Date_of_Month], '') <> ISNULL(src.[Last_Date_of_Month], '')
		OR ISNULL(tgt.[First_Date_of_Quarter], '') <> ISNULL(src.[First_Date_of_Quarter], '')
		OR ISNULL(tgt.[Last_Date_of_Quarter], '') <> ISNULL(src.[Last_Date_of_Quarter], '')
		OR ISNULL(tgt.[First_Date_of_Year], '') <> ISNULL(src.[First_Date_of_Year], '')
		OR ISNULL(tgt.[Last_Date_of_Year], '') <> ISNULL(src.[Last_Date_of_Year], '')
		OR ISNULL(tgt.[is_Holiday], '') <> ISNULL(src.[is_Holiday], '')
		OR ISNULL(tgt.[is_Holiday_Season], '') <> ISNULL(src.[is_Holiday_Season], '')
		OR ISNULL(tgt.[Holiday_Name], '') <> ISNULL(src.[Holiday_Name], '')
		OR ISNULL(tgt.[Holiday_Season_Name], '') <> ISNULL(src.[Holiday_Season_Name], '')
		OR ISNULL(tgt.[is_Weekday], '') <> ISNULL(src.[is_Weekday], '')
		OR ISNULL(tgt.[is_Business_Day], '') <> ISNULL(src.[is_Business_Day], '')
		OR ISNULL(tgt.[Previous_Business_Day], '') <> ISNULL(src.[Previous_Business_Day], '')
		OR ISNULL(tgt.[Next_Business_Day], '') <> ISNULL(src.[Next_Business_Day], '')
		OR ISNULL(tgt.[is_Leap_Year], '') <> ISNULL(src.[is_Leap_Year], '')
		OR ISNULL(tgt.[Days_in_Month], '') <> ISNULL(src.[Days_in_Month], '')
		OR ISNULL(tgt.[Fiscal_Day_of_Year], '') <> ISNULL(src.[Fiscal_Day_of_Year], '')
		OR ISNULL(tgt.[Fiscal_Week_of_Year], '') <> ISNULL(src.[Fiscal_Week_of_Year], '')
		OR ISNULL(tgt.[Fiscal_Month], '') <> ISNULL(src.[Fiscal_Month], '')
		OR ISNULL(tgt.[Fiscal_Quarter], '') <> ISNULL(src.[Fiscal_Quarter], '')
		OR ISNULL(tgt.[Fiscal_Quarter_Name], '') <> ISNULL(src.[Fiscal_Quarter_Name], '')
		OR ISNULL(tgt.[Fiscal_Quarter_Year_Name], '') <> ISNULL(src.[Fiscal_Quarter_Year_Name], '')
		OR ISNULL(tgt.[Fiscal_Year], '') <> ISNULL(src.[Fiscal_Year], '')
		OR ISNULL(tgt.[Fiscal_Year_Name], '') <> ISNULL(src.[Fiscal_Year_Name], '')
		OR ISNULL(tgt.[Fiscal_Month_Year], '') <> ISNULL(src.[Fiscal_Month_Year], '')
		OR ISNULL(tgt.[Fiscal_MMYYYY], '') <> ISNULL(src.[Fiscal_MMYYYY], '')
		OR ISNULL(tgt.[Fiscal_First_Day_of_Month], '') <> ISNULL(src.[Fiscal_First_Day_of_Month], '')
		OR ISNULL(tgt.[Fiscal_Last_Day_of_Month], '') <> ISNULL(src.[Fiscal_Last_Day_of_Month], '')
		OR ISNULL(tgt.[Fiscal_First_Day_of_Quarter], '') <> ISNULL(src.[Fiscal_First_Day_of_Quarter], '')
		OR ISNULL(tgt.[Fiscal_Last_Day_of_Quarter], '') <> ISNULL(src.[Fiscal_Last_Day_of_Quarter], '')
		OR ISNULL(tgt.[Fiscal_First_Day_of_Year], '') <> ISNULL(src.[Fiscal_First_Day_of_Year], '')
		OR ISNULL(tgt.[Fiscal_Last_Day_of_Year], '') <> ISNULL(src.[Fiscal_Last_Day_of_Year], '')
		OR ISNULL(tgt.[is_Removed_From_Source], '') <> ISNULL(src.[is_Removed_From_Source], '')
		--,src.[is_Excluded] --ADMIN FIELD NOT USED FOR UPDATE MATCHING
		--,src.[ETL_Created_Date]
		--,src.[ETL_Modified_Date]
		--,src.[ETL_Modified_Count]
		THEN
			UPDATE
			SET [Calendar_Date] = src.[Calendar_Date]
				,[Calendar_Month] = src.[Calendar_Month]
				,[Calendar_Day] = src.[Calendar_Day]
				,[Calendar_Year] = src.[Calendar_Year]
				,[Calendar_Quarter] = src.[Calendar_Quarter]
				,[Calendar_Quarter_Name] = src.[Calendar_Quarter_Name]
				,[Calendar_Quarter_Year_Name] = src.[Calendar_Quarter_Year_Name]
				,[Day_Name] = src.[Day_Name]
				,[Day_of_Week] = src.[Day_of_Week]
				,[Day_of_Week_in_Month] = src.[Day_of_Week_in_Month]
				,[Day_of_Week_in_Year] = src.[Day_of_Week_in_Year]
				,[Day_of_Week_in_Quarter] = src.[Day_of_Week_in_Quarter]
				,[Day_of_Quarter] = src.[Day_of_Quarter]
				,[Day_of_Year] = src.[Day_of_Year]
				,[Week_of_Month] = src.[Week_of_Month]
				,[Week_of_Quarter] = src.[Week_of_Quarter]
				,[Week_of_Year] = src.[Week_of_Year]
				,[Month_Name] = src.[Month_Name]
				,[First_Date_of_Week] = src.[First_Date_of_Week]
				,[Last_Date_of_Week] = src.[Last_Date_of_Week]
				,[First_Date_of_Month] = src.[First_Date_of_Month]
				,[Last_Date_of_Month] = src.[Last_Date_of_Month]
				,[First_Date_of_Quarter] = src.[First_Date_of_Quarter]
				,[Last_Date_of_Quarter] = src.[Last_Date_of_Quarter]
				,[First_Date_of_Year] = src.[First_Date_of_Year]
				,[Last_Date_of_Year] = src.[Last_Date_of_Year]
				,[is_Holiday] = src.[is_Holiday]
				,[is_Holiday_Season] = src.[is_Holiday_Season]
				,[Holiday_Name] = src.[Holiday_Name]
				,[Holiday_Season_Name] = src.[Holiday_Season_Name]
				,[is_Weekday] = src.[is_Weekday]
				,[is_Business_Day] = src.[is_Business_Day]
				,[Previous_Business_Day] = src.[Previous_Business_Day]
				,[Next_Business_Day] = src.[Next_Business_Day]
				,[is_Leap_Year] = src.[is_Leap_Year]
				,[Days_in_Month] = src.[Days_in_Month]
				,[Fiscal_Day_of_Year] = src.[Fiscal_Day_of_Year]
				,[Fiscal_Week_of_Year] = src.[Fiscal_Week_of_Year]
				,[Fiscal_Month] = src.[Fiscal_Month]
				,[Fiscal_Quarter] = src.[Fiscal_Quarter]
				,[Fiscal_Quarter_Name] = src.[Fiscal_Quarter_Name]
				,[Fiscal_Quarter_Year_Name] = src.[Fiscal_Quarter_Year_Name]
				,[Fiscal_Year] = src.[Fiscal_Year]
				,[Fiscal_Year_Name] = src.[Fiscal_Year_Name]
				,[Fiscal_Month_Year] = src.[Fiscal_Month_Year]
				,[Fiscal_MMYYYY] = src.[Fiscal_MMYYYY]
				,[Fiscal_First_Day_of_Month] = src.[Fiscal_First_Day_of_Month]
				,[Fiscal_Last_Day_of_Month] = src.[Fiscal_Last_Day_of_Month]
				,[Fiscal_First_Day_of_Quarter] = src.[Fiscal_First_Day_of_Quarter]
				,[Fiscal_Last_Day_of_Quarter] = src.[Fiscal_Last_Day_of_Quarter]
				,[Fiscal_First_Day_of_Year] = src.[Fiscal_First_Day_of_Year]
				,[Fiscal_Last_Day_of_Year] = src.[Fiscal_Last_Day_of_Year]
				,[is_Removed_From_Source] = src.[is_Removed_From_Source]
				,[ETL_Modified_Date] = src.[ETL_Modified_Date]
				,[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count], 1) + 1)
	WHEN NOT MATCHED BY SOURCE
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
