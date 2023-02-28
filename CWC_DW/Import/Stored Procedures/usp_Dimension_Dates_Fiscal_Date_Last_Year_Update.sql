
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE PROC [Import].[usp_Dimension_Dates_Fiscal_Date_Last_Year_Update]

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	WITH src AS
		(
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
	WHERE ISNULL(d.[Fiscal_Date_Last_Year],'') <> ISNULL(src.[Fiscal_Date_Last_Year],'');

END TRY

BEGIN CATCH

	DECLARE @InputParameters NVARCHAR(MAX)
	If @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT @InputParameters = '';
	EXEC Administration.usp_ErrorLogger_Insert @InputParameters;

END CATCH