SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[PrintSuitesResultsForSession]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[PrintSuitesResultsForSession] AS' 
END
GO

-- =======================================================================
-- PROCEDURE: PrintSuitesResultsForSession
-- It will print all the results of the current test session. 
-- =======================================================================
ALTER   PROCEDURE [internal].[PrintSuitesResultsForSession]
   @TestSessionId   int,            -- Identifies the test session.
   @ResultsFormat   varchar(10),    -- Indicates if the format in which the results will be printed.
                                    -- See the coments at the begining of the file under section 'Results Format'
   @Verbose          bit            -- If 1 then the output will contain all suites and tests names and all the log entries.
                                    -- If 0 then the output will contain all suites and tests names but only the 
                                    -- log entries indicating failures.
AS
BEGIN

   DECLARE @SuitesNodeWasCreated          bit
   DECLARE @SuitesNodeWasClosed           bit
   DECLARE @SuiteId                       int
   DECLARE @SuiteTypeId                   int
   DECLARE @SuiteName                     sysname
   DECLARE @CountOfPassedTestInSuite      int
   DECLARE @CountOfIgnoredTestInSuite     int
   DECLARE @CountOfFailedTestInSuite      int
   DECLARE @CountOfTestInSuite            int

   DECLARE CrsSuiteResults CURSOR LOCAL FOR
   SELECT SuiteId, Internal.SFN_GetSuiteTypeId(SuiteName), SuiteName FROM Data.TSTResults 
   WHERE TestSessionId = @TestSessionId
   GROUP BY SuiteId, SuiteName
   ORDER BY Internal.SFN_GetSuiteTypeId(SuiteName), SuiteName

   SET @SuitesNodeWasCreated  = 0
   SET @SuitesNodeWasClosed   = 0

   OPEN CrsSuiteResults
   FETCH NEXT FROM CrsSuiteResults INTO @SuiteId, @SuiteTypeId, @SuiteName
   WHILE @@FETCH_STATUS = 0
   BEGIN

      IF (@ResultsFormat = 'XML')
      BEGIN
         IF (@SuitesNodeWasCreated = 0 AND @SuiteTypeId != 0 AND @SuiteTypeId != 3)
         BEGIN
            PRINT REPLICATE(' ', 2) + '<Suites>'
            SET @SuitesNodeWasCreated = 1
         END

         IF (@SuitesNodeWasCreated = 1 AND @SuitesNodeWasClosed = 0 AND @SuiteTypeId = 3)
         BEGIN
            PRINT REPLICATE(' ', 2) + '</Suites>'
            SET @SuitesNodeWasClosed  = 1
         END
      END

      SET @CountOfTestInSuite = Internal.SFN_GetCountOfTestsInSuite(@SuiteId) 
      SET @CountOfFailedTestInSuite = Internal.SFN_GetCountOfFailedTestsInSuite(@SuiteId)
      SET @CountOfIgnoredTestInSuite = Internal.SFN_GetCountOfIgnoredTestsInSuite(@SuiteId)
      SET @CountOfPassedTestInSuite = Internal.SFN_GetCountOfPassedTestsInSuite(@SuiteId)
      
      IF (@ResultsFormat = 'Text')
      BEGIN
         -- The "session setup suite" and "session teardown suite" are not really suites.
         IF (@SuiteTypeId != 0 AND @SuiteTypeId != 3)
         BEGIN
            PRINT REPLICATE(' ', 4) + 'Suite: ' + ISNULL(@SuiteName, 'Anonymous') + '. Tests: ' + CAST(@CountOfTestInSuite as nvarchar(10)) + '. Passed: ' + CAST(@CountOfPassedTestInSuite as nvarchar(10)) + '. Ignored: ' + CAST(@CountOfIgnoredTestInSuite as nvarchar(10)) + '. Failed: ' + CAST(@CountOfFailedTestInSuite as nvarchar(10))
         END
      END
      ELSE IF (@ResultsFormat = 'XML')
      BEGIN
         -- The "session setup suite" and "session teardown suite" are not really suites.
         IF (@SuiteTypeId != 0 AND @SuiteTypeId != 3)
         BEGIN
            PRINT REPLICATE(' ', 4) + '<Suite' + 
               ' suiteName="' + ISNULL(@SuiteName, 'Anonymous') + '"' + 
               ' testsCount="' + CAST(@CountOfTestInSuite as nvarchar(10)) + '"' + 
               ' passedCount="' + CAST(@CountOfPassedTestInSuite as nvarchar(10)) + '"' + 
               ' ignoredCount="' + CAST(@CountOfIgnoredTestInSuite as nvarchar(10)) + '"' + 
               ' failedCount="' + CAST(@CountOfFailedTestInSuite as nvarchar(10)) + '"' + 
               ' >'
         END
      END

      EXEC Internal.PrintOneSuiteResults @SuiteId, @SuiteTypeId, @ResultsFormat, @Verbose

      IF (@ResultsFormat = 'XML')
      BEGIN
         -- The "session setup suite" and "session teardown suite" are not really suites.
         IF (@SuiteTypeId != 0 AND @SuiteTypeId != 3)
         BEGIN
            PRINT REPLICATE(' ', 4) + '</Suite>'
         END
      END

      FETCH NEXT FROM CrsSuiteResults INTO @SuiteId, @SuiteTypeId, @SuiteName
   END

   CLOSE CrsSuiteResults
   DEALLOCATE CrsSuiteResults

   IF (@ResultsFormat = 'XML')
   BEGIN
      IF (@SuitesNodeWasCreated = 1 AND @SuitesNodeWasClosed = 0)
      BEGIN
         PRINT REPLICATE(' ', 2) + '</Suites>'
         SET @SuitesNodeWasClosed  = 1
      END
   END

END
GO
