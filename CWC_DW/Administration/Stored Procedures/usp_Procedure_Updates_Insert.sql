
CREATE PROCEDURE [Administration].[usp_Procedure_Updates_Insert] (
	@procedureName AS VARCHAR(50)
	,@procedureUpdateKey AS INT OUTPUT
	)
	/*
Description         : Procedure used to start Procedure_UpdatesLoggin
Created date		: 2023-03-14
Created By          : Carlos Carrillo

Start Revision History            
-----------------------------------------------------------------------------------------------
Date          Developer           Revision Description
----------    --------------      -------------------------------------------------------------

-----------------------------------------------------------------------------------------------
End   Revision   History
*/
AS
BEGIN TRY
	INSERT INTO [Administration].[Procedure_Updates] (
		[Procedure_Name]
		,[Status]
		)
	VALUES (
		@procedureName
		,'RUNNING'
		)

	SET @procedureUpdateKey = (
			SELECT SCOPE_IDENTITY()
			)
END TRY

BEGIN CATCH
	DECLARE @InputParameters NVARCHAR(MAX)

	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SELECT @InputParameters = '';

	EXEC Administration.usp_Error_Logger_Insert @InputParameters;
END CATCH