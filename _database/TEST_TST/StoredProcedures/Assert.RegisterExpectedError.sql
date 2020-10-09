SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: RegisterExpectedError
-- Can be called by the test procedures to register an expected error.
-- TODO: Error out if all error params are null
-- TODO: Add severity and level
-- =======================================================================
CREATE PROCEDURE Assert.RegisterExpectedError
   @ContextMessage            nvarchar(1000),
   @ExpectedErrorMessage      nvarchar(2048) = NULL,
   @ExpectedErrorProcedure    nvarchar(126) = NULL,
   @ExpectedErrorNumber       int = NULL
AS
BEGIN

   DECLARE @Stage          char
   DECLARE @ErrorMessage   nvarchar(1000)

   SELECT @Stage = Stage FROM #Tmp_CrtSessionInfo
   
   IF(@Stage != 'T')
   BEGIN
      IF (@Stage = 'A')
      BEGIN
         SET @ErrorMessage = 'The test session setup procedure cannot invoke RegisterExpectedError. RegisterExpectedError can only be invoked by a test procedure before the error is raised.'
      END
      ELSE IF (@Stage = 'S')
      BEGIN
         SET @ErrorMessage = 'A setup procedure cannot invoke RegisterExpectedError. RegisterExpectedError can only be invoked by a test procedure before the error is raised.'
      END
      ELSE IF  (@Stage = 'X')
      BEGIN
         SET @ErrorMessage = 'A teardown procedure cannot invoke RegisterExpectedError. RegisterExpectedError can only be invoked by a test procedure before the error is raised.'
      END
      ELSE IF  (@Stage = 'Z')
      BEGIN
         SET @ErrorMessage = 'The test session teardown procedure cannot invoke RegisterExpectedError. RegisterExpectedError can only be invoked by a test procedure before the error is raised.'
      END
      ELSE 
      BEGIN
         SET @ErrorMessage = 'TST Internal Error. RegisterExpectedError appears to be called outside of any test context.'
      END

      EXEC Internal.LogErrorMessageAndRaiseError @ErrorMessage
      
   END

   UPDATE #Tmp_CrtSessionInfo SET 
      ExpectedErrorNumber          = @ExpectedErrorNumber          ,
      ExpectedErrorMessage         = @ExpectedErrorMessage         ,
      ExpectedErrorProcedure       = @ExpectedErrorProcedure       ,
      ExpectedErrorContextMessage  = @ContextMessage  

END

GO
