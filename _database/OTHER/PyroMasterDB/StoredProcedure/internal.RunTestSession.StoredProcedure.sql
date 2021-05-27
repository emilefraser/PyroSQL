SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[RunTestSession]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[RunTestSession] AS' 
END
GO

-- =======================================================================
-- PROCEDURE: RunTestSession
-- Called by RunSuite or RunTest.
-- Assumes all the data regarding the test session was prepared by 
-- PrepareTestSessionInformation
-- Return code:
--    0 - OK. All appropiate tests were run.
--    1 - Error. Suite not found or no suites were defined.
-- =======================================================================
ALTER   PROCEDURE [internal].[RunTestSession]
   @TestSessionId       int,              -- Identifies the test session.
   @SuiteName           sysname = NULL    -- The suite that must be run. If not specified then 
                                          -- tests in all suites will be run.
AS
BEGIN

   DECLARE @SuiteId                 int
   DECLARE @LogMessage              nvarchar(max)
   DECLARE @CountSuite              int
   DECLARE @TestSessionSetupResult  int
   
   IF @SuiteName IS NOT NULL
   BEGIN
      SELECT @SuiteId = SuiteId FROM Data.Suite WHERE TestSessionId = @TestSessionId AND SuiteName = @SuiteName
      IF @SuiteId IS NULL
      BEGIN
         SET @LogMessage = 'Suite ''' + @SuiteName + ''' not found'
         EXEC Internal.LogErrorMessage @LogMessage
         RETURN 1
      END
   END
   
   EXEC @TestSessionSetupResult = Internal.RunTestSessionSetup @TestSessionId
   IF (@TestSessionSetupResult != 0) GOTO LblBeforeSessionTeardown

   IF @SuiteName IS NOT NULL
   BEGIN
      EXEC Internal.RunOneSuiteInternal @TestSessionId, @SuiteId
   END
   ELSE
   BEGIN

      DECLARE CrsSuites CURSOR LOCAL FOR 
      SELECT SuiteId 
      FROM Data.Suite 
      WHERE TestSessionId = @TestSessionId
      ORDER BY SuiteId

      OPEN CrsSuites
      FETCH NEXT FROM CrsSuites INTO @SuiteId
      WHILE @@FETCH_STATUS = 0
      BEGIN
         EXEC Internal.RunOneSuiteInternal @TestSessionId, @SuiteId
         FETCH NEXT FROM CrsSuites INTO @SuiteId
      END

      CLOSE CrsSuites
      DEALLOCATE CrsSuites
   END

LblBeforeSessionTeardown:

   EXEC Internal.RunTestSessionTeardown @TestSessionId

   RETURN 0
END
GO
