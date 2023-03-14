


CREATE  PROCEDURE [Administration].[ProcedureUpdateSet] (@procedureName as varchar(50),@procedureUpdateKey as int OUTPUT)
/*
Description         : Procedure used to start procedureUpdatesLoggin
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

			INSERT INTO [Administration].[ProcedureUpdates]
			   (
				[ProcedureName]
			   ,[Status])
			VALUES
			   (
				@procedureName
			   ,'RUNNING')
			SET @procedureUpdateKey = 	(SELECT SCOPE_IDENTITY() )

END TRY  

BEGIN CATCH

	DECLARE @InputParameters NVARCHAR(MAX)
	If @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT @InputParameters = '';
	EXEC Administration.usp_ErrorLogger_Insert @InputParameters;

END CATCH