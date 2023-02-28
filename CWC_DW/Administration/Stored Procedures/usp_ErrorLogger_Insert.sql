

CREATE PROCEDURE Administration.usp_ErrorLogger_Insert @InputParameters [nvarchar](max)
WITH EXECUTE AS CALLER
AS
BEGIN
  DECLARE @ERROR_SEVERITY INT,
          @ERROR_STATE INT,
          @ERROR_NUMBER INT,
          @ERROR_LINE INT,
          @ERROR_MESSAGE VARCHAR(245),
          @ERROR_PROCEDURE VARCHAR(100);

  SELECT @ERROR_SEVERITY = ERROR_SEVERITY(),
         @ERROR_STATE = ERROR_STATE(),
         @ERROR_NUMBER = ERROR_NUMBER(),
         @ERROR_LINE = ERROR_LINE(), 
         @ERROR_MESSAGE = ERROR_MESSAGE(),
         @ERROR_PROCEDURE = ERROR_PROCEDURE();

  SET NOCOUNT ON;
 
    INSERT INTO Administration.ErrorLogger (StoredProcedure, InputParameters, ErrorSeverity,
                             ErrorState, ErrorLine, ErrorNumber, ErrorMessage)
    SELECT @ERROR_PROCEDURE, @InputParameters, @ERROR_SEVERITY,
           @ERROR_STATE, @ERROR_LINE, @ERROR_NUMBER, @ERROR_MESSAGE;




END