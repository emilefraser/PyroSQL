SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE PrepareTestSessionInformation
-- Analyses the given database and prepares all the information needed 
-- to run a test session in the given database.
-- Basically it detects all the TST test procedures for the given 
-- @TestDatabaseName, @TargetSuiteName and @TargetTestName.
-- Return code:
--    0 - OK
--    1 - An error was detected. For example:
--        The database given by @TestDatabaseName was not found or
--        @TargetSuiteName was specified and the suite given by @TargetSuiteName was not found or
--        @TargetTestName was specified and the test given by @TargetTestName was not found or
--        @TargetTestName was specified and the test name does not follow naming conventions for a TST test procedure.
--        No tests were detected that match the input parameters.
--        In case of an error an error message is stored in one of the log tables.
-- Note: This sproc will raise an error if the parameters are invalid in 
--       a way that indicates an internal error.
-- =======================================================================
CREATE PROCEDURE Internal.PrepareTestSessionInformation
   @TestSessionId          int,              -- Identifies the test session.
   @TestProcedurePrefix    varchar(100),     -- The prefix used to identify the test stored procedures
   @TestDatabaseName       sysname,          -- Specifies the database where the suite analysis is done.
   @TargetSuiteName        sysname,          -- The target suite name. It can be NULL and then all suites are candidates.
   @TargetTestName         sysname           -- The target test name. It can be NULL and then all tests are candidates.
AS
BEGIN

   DECLARE @ErrorMessage         nvarchar(1000)
   DECLARE @SqlCommand           nvarchar(1000)
   DECLARE @SuiteName            sysname
   DECLARE @IsTSTSproc           bit
   DECLARE @SProcType            varchar(10)
   DECLARE @SchemaName           sysname
   DECLARE @SProcName            sysname
   DECLARE @SuiteId              int
   DECLARE @DuplicateSuiteName   sysname
   DECLARE @DuplicateTestName    sysname
   DECLARE @ResultCode           int

   CREATE TABLE #Tmp_Procedures (
      SchemaName sysname NULL,
      SProcName sysname NOT NULL
   )
      
   IF (@TestDatabaseName IS NULL) 
   BEGIN
      RAISERROR('TST Internal Error. Invalid call to PrepareTestSessionInformation. @TestDatabaseName must be specified.', 16, 1)
      RETURN 1
   END

   IF (@TargetSuiteName IS NOT NULL AND @TargetTestName IS NOT NULL) 
   BEGIN
      RAISERROR('TST Internal Error. Invalid call to PrepareTestSessionInformation. @TargetSuiteName and @TargetTestName cannot both be specified.', 16, 1)
      RETURN 1
   END

   -- @TestDatabaseName must exist
   IF NOT EXISTS (SELECT [name] FROM sys.databases WHERE [name] = @TestDatabaseName)
   BEGIN
      SET @ErrorMessage = 'Database ''' + @TestDatabaseName + ''' not found.'
      EXEC Internal.LogErrorMessage @ErrorMessage
      RETURN 1
   END

   SELECT @SqlCommand = 
      'INSERT INTO #Tmp_Procedures ' + 
      'SELECT Schemas.name AS SchemaName, Procedures.name AS SProcName ' + 
      'FROM ' + QUOTENAME(@TestDatabaseName) + '.sys.procedures AS Procedures ' + 
      'INNER JOIN ' + QUOTENAME(@TestDatabaseName) + '.sys.schemas AS Schemas ON Schemas.schema_id = Procedures.schema_id ' + 
      'WHERE is_ms_shipped = 0 ORDER BY Procedures.name'

   EXEC (@SqlCommand)

   -- If @TargetTestName is specified then it must follow the TST naming conventions for a test name.
   -- At this point we must also determine its suite name so that the following loop can isolate its SETUP and TEARDOWN.
   IF @TargetTestName IS NOT NULL
   BEGIN
      EXEC Internal.AnalyzeSprocName @TargetTestName, @TestProcedurePrefix, @TargetSuiteName OUTPUT, @IsTSTSproc OUTPUT, @SProcType OUTPUT
      IF (@IsTSTSproc = 0 OR @SProcType != 'Test')
      BEGIN
         SET @ErrorMessage = 'Test procedure''' + @TargetTestName + ''' does not follow the naming conventions for a TST test procedure.'
         EXEC Internal.LogErrorMessage @ErrorMessage
         RETURN 1
      END
   END

   EXEC @ResultCode = Internal.PrepareTestSessionSetupInformation @TestSessionId, @TestProcedurePrefix
   IF(@ResultCode != 0) RETURN 1

   EXEC @ResultCode = Internal.PrepareTestSessionTeardownInformation @TestSessionId, @TestProcedurePrefix
   IF(@ResultCode != 0) RETURN 1

   DECLARE CrsTests CURSOR LOCAL FOR
   SELECT 
      SchemaName,
      SProcName
   FROM #Tmp_Procedures 
   WHERE
      SProcName LIKE (@TestProcedurePrefix + '%')
      AND (
               (SProcName = @TargetTestName) 
            OR (@TargetSuiteName IS NULL AND @TargetTestName IS NULL) 
            OR (SProcName = @TestProcedurePrefix + 'SETUP_' + @TargetSuiteName)
            OR (SProcName = @TestProcedurePrefix + 'TEARDOWN_' + @TargetSuiteName)
            OR (@TargetTestName IS NULL AND SProcName Like @TestProcedurePrefix + @TargetSuiteName + '#%')
          )
      AND SProcName != @TestProcedurePrefix + 'SESSION_SETUP'
      AND SProcName != @TestProcedurePrefix + 'SESSION_TEARDOWN'
               
   OPEN CrsTests
   FETCH NEXT FROM CrsTests INTO @SchemaName, @SProcName
   WHILE @@FETCH_STATUS = 0
   BEGIN
      EXEC Internal.AnalyzeSprocName @SProcName, @TestProcedurePrefix, @SuiteName OUTPUT, @IsTSTSproc OUTPUT, @SProcType OUTPUT
      IF(@IsTSTSproc = 1)
      BEGIN

         -- TODO: validate the suite and test name
         IF (@TargetSuiteName IS NULL OR @TargetSuiteName = @SuiteName)
         BEGIN

            EXEC Internal.EnsureSuite @TestSessionId, @SchemaName, @SuiteName, @SuiteId OUTPUT
            INSERT INTO Data.Test(TestSessionId, SuiteId, SchemaName, SProcName, SProcType) VALUES (@TestSessionId, @SuiteId, @SchemaName, @SProcName, @SProcType)
         END
                  
      END
     
      FETCH NEXT FROM CrsTests INTO @SchemaName, @SProcName
   END

   CLOSE CrsTests
   DEALLOCATE CrsTests
   
   -- If @TargetTestName is specified then it must exist
   IF (@TargetTestName IS NOT NULL)
   BEGIN
      IF NOT EXISTS (SELECT 1 FROM Data.Test WHERE TestSessionId = @TestSessionId AND SProcName = @TargetTestName AND Test.SProcType = 'Test')
      BEGIN
         SET @ErrorMessage = 'Test procedure ''' + @TargetTestName + ''' not found in database ''' + @TestDatabaseName + '''.'
         EXEC Internal.LogErrorMessage @ErrorMessage
         RETURN 1
      END
   END

   IF (@TargetSuiteName IS NOT NULL)
   BEGIN
   
      -- If @TargetSuiteName is specified then it must exist.
      IF NOT EXISTS (SELECT 1 FROM Data.Suite WHERE TestSessionId = @TestSessionId AND SuiteName = @TargetSuiteName)
      BEGIN
         SET @ErrorMessage = 'Suite ''' + @TargetSuiteName + ''' not found in database ''' + @TestDatabaseName + '''.'
         EXEC Internal.LogErrorMessage @ErrorMessage
         RETURN 1
      END
   
      -- There must be at least one test defined for that suite.   
      IF NOT EXISTS (
         SELECT 1 
         FROM Data.Test 
         INNER JOIN Data.Suite ON Suite.SuiteId = Test.SuiteId
         WHERE Suite.TestSessionId = @TestSessionId AND Suite.SuiteName = @TargetSuiteName AND Test.SProcType = 'Test')
      BEGIN
         SET @ErrorMessage = 'Suite ''' + @TargetSuiteName + ''' in database ''' + @TestDatabaseName + ''' does not contain any test'
         EXEC Internal.LogErrorMessage @ErrorMessage
         RETURN 1
      END
   END
      
   -- There must be at least one test detected as a result of the analysis
   IF NOT EXISTS (
      SELECT 1 
      FROM Data.Test 
      WHERE Test.TestSessionId = @TestSessionId AND SProcType = 'Test')
   BEGIN
      SET @ErrorMessage = 'No test procedure was detected for the given search criteria in database ''' + @TestDatabaseName + '''.'
      EXEC Internal.LogErrorMessage @ErrorMessage
      RETURN 1
   END

   -- It is illegal to have two suites with the same name. This can happen if they are in different schemas.
   SET @DuplicateSuiteName = NULL
   SELECT @DuplicateSuiteName = SuiteName
   FROM TST.Data.Suite
   WHERE TestSessionId = @TestSessionId
   GROUP BY TestSessionId, SuiteName
   HAVING COUNT(*) > 1
   
   IF (@DuplicateSuiteName IS NOT NULL)
   BEGIN
      SET @ErrorMessage = 'The suite name ''' + @DuplicateSuiteName + ''' appears to be duplicated across different schemas in database ''' + @TestDatabaseName + '''.'
      EXEC Internal.LogErrorMessage @ErrorMessage
      RETURN 1
   END
   
   -- It is illegal to have two tests with the same name. This can happen if they are in the anonymous suite and in different schemas.
   SET @DuplicateTestName = NULL
   SELECT @DuplicateTestName = SProcName
   FROM TST.Data.Test
   WHERE TestSessionId = @TestSessionId
   GROUP BY TestSessionId, SProcName
   HAVING COUNT(*) > 1
   
   IF (@DuplicateTestName IS NOT NULL)
   BEGIN
      SET @ErrorMessage = 'The test name ''' + @DuplicateTestName + ''' appears to be duplicated across different schemas in database ''' + @TestDatabaseName + '''.'
      EXEC Internal.LogErrorMessage @ErrorMessage
      RETURN 1
   END

   RETURN 0
END

GO
