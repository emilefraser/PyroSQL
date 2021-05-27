SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[GetExpectedErrorInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[GetExpectedErrorInfo] AS' 
END
GO


-- =======================================================================
-- PROCEDURE GetExpectedErrorInfo
-- Retrieves information about the current expected error. 
-- If no expected error is registered then at return 
-- @ExpectedErrorContextMessage and @ExpectedErrorInfo will be NULL.
-- If an expected error is registered then at return 
-- @ExpectedErrorContextMessage and @ExpectedErrorInfo will contain the 
-- appropiate information (See RegisterExpectedError)
-- =======================================================================
ALTER   PROCEDURE [internal].[GetExpectedErrorInfo]
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
