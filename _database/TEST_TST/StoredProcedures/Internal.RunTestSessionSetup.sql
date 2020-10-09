SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: RunTestSessionSetup
-- Runs the test session setup. 
-- Return code:
--    0 - OK. No test session setup procedure was found or it was found, executed and passed. 
--    1 - The test session setup procedure was found, executed and failed. 
-- =======================================================================
CREATE PROCEDURE Internal.RunTestSessionSetup
   @TestSessionId       int               -- Identifies the test session.
AS
BEGIN

   DECLARE @SessionSetupSProcId int

   SELECT @SessionSetupSProcId = TestId FROM Data.Test WHERE TestSessionId = @TestSessionId AND SProcType = 'SetupS'
   IF (@SessionSetupSProcId IS NOT NULL) 
   BEGIN TRY
      UPDATE #Tmp_CrtSessionInfo SET TestId = @SessionSetupSProcId, Stage = 'A'
      EXEC Internal.RunSessionLevelSProc @TestSessionId, @SessionSetupSProcId
   END TRY
   BEGIN CATCH

      DECLARE @ErrorMessage         nvarchar(4000)
      DECLARE @FullSprocName        nvarchar(1000)
      SET @FullSprocName = Internal.SFN_GetFullSprocName(@SessionSetupSProcId)

      -- If this is an error raised by the TST API (like Assert) we don't have to log the error, it was already logged.
      IF (ERROR_MESSAGE() != 'TST RAISERROR {6C57D85A-CE44-49ba-9286-A5227961DF02}') 
      BEGIN
         SET @ErrorMessage =  'An error occured during the execution of the test procedure ''' + @FullSprocName + 
                              '''. Error: ' + CAST(ERROR_NUMBER() AS varchar) + ', ' + ERROR_MESSAGE() + 
                              ' Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A') + '. Line: ' + CAST(ERROR_LINE() AS varchar)
         EXEC Internal.LogErrorMessage @ErrorMessage
      END

      EXEC Internal.LogErrorMessage 'The test session will be aborted. No tests will be run. The execution will continue with the test session teardown.'

      RETURN 1
   END CATCH

   RETURN 0

END

GO
