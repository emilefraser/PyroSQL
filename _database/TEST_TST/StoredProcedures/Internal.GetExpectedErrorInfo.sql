SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =======================================================================
-- PROCEDURE GetExpectedErrorInfo
-- Retrieves information about the current expected error. 
-- If no expected error is registered then at return 
-- @ExpectedErrorContextMessage and @ExpectedErrorInfo will be NULL.
-- If an expected error is registered then at return 
-- @ExpectedErrorContextMessage and @ExpectedErrorInfo will contain the 
-- appropiate information (See RegisterExpectedError)
-- =======================================================================
CREATE PROCEDURE Internal.GetExpectedErrorInfo
   @ExpectedErrorContextMessage  nvarchar(1000) OUT, 
   @ExpectedErrorInfo            nvarchar(2000) OUT 
AS
BEGIN

   DECLARE @ExpectedErrorNumber           int
   DECLARE @ExpectedErrorMessage          nvarchar(2048) 
   DECLARE @ExpectedErrorProcedure        nvarchar(126)

   SET @ExpectedErrorInfo           = NULL
   SET @ExpectedErrorContextMessage = NULL

   SELECT 
      @ExpectedErrorNumber          = ExpectedErrorNumber         ,
      @ExpectedErrorMessage         = ExpectedErrorMessage        ,
      @ExpectedErrorProcedure       = ExpectedErrorProcedure      ,
      @ExpectedErrorContextMessage  = ExpectedErrorContextMessage
   FROM #Tmp_CrtSessionInfo

   IF (     (@ExpectedErrorNumber IS NOT NULL) 
         OR (@ExpectedErrorMessage IS NOT NULL) 
         OR (@ExpectedErrorProcedure IS NOT NULL) )
   BEGIN
      SET @ExpectedErrorInfo = 
         'Error number: ' + ISNULL(CAST(@ExpectedErrorNumber AS varchar), 'N/A') +
         ' Procedure: ''' + ISNULL(@ExpectedErrorProcedure, 'N/A') + '''' + 
         ' Message: ' + ISNULL(@ExpectedErrorMessage, 'N/A')
      SET @ExpectedErrorContextMessage = ISNULL(@ExpectedErrorContextMessage, '')
   END
   
END

GO
