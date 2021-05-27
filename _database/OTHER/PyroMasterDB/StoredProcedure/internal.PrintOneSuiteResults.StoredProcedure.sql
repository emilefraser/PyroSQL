SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[PrintOneSuiteResults]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[PrintOneSuiteResults] AS' 
END
GO


-- =======================================================================
-- PROCEDURE: PrintOneSuiteResults
-- It will print the results for the given test suite. Called by PrintSuitesResultsForSession
-- =======================================================================
ALTER   PROCEDURE [internal].[PrintOneSuiteResults] 
   @SuiteId          int,              -- Identifies the suite.
   @SuiteTypeId      int,              -- Identifies the type of suite. See Internal.SFN_GetSuiteTypeId.
   @ResultsFormat    varchar(10),      -- Indicates if the format in which the results will be printed.
                                       -- See the coments at the begining of the file under section 'Results Format'
   @Verbose          bit               -- If 1 then the output will contain all suites and tests names and all the log entries.
                                       -- If 0 then the output will contain all suites and tests names but only the 
                                       -- log entries indicating failures.
AS
BEGIN

   DECLARE @TestId               int
   DECLARE @SProcType            varchar(10)
   DECLARE @SProcName            sysname
   DECLARE @TestStatus           nvarchar(10)
   DECLARE @FailOrErrorEntries   int
   DECLARE @IgnoreEntries        int

   DECLARE CrsTestsResults CURSOR LOCAL FOR
   SELECT TestId, SProcType, SProcName FROM Data.TSTResults 
   WHERE SuiteId = @SuiteId
   GROUP BY TestId, SProcType, SProcName
   ORDER BY TestId

   IF (@ResultsFormat = 'XML')
   BEGIN
      -- The session seup and session teardown are handled differently.
      IF(@SuiteTypeId != 0 AND @SuiteTypeId != 3)
      BEGIN
         PRINT REPLICATE(' ', 6) + '<Tests>'
      END
   END

   OPEN CrsTestsResults
   FETCH NEXT FROM CrsTestsResults INTO @TestId, @SProcType, @SProcName
   WHILE @@FETCH_STATUS = 0
   BEGIN

      SET @FailOrErrorEntries = Internal.SFN_GetCountOfFailOrErrorEntriesForTest(@TestId)
      SET @IgnoreEntries = Internal.SFN_GetCountOfIgnoreEntriesForTest(@TestId)

      IF(@FailOrErrorEntries != 0) SET @TestStatus = 'Failed'
      ELSE IF (@IgnoreEntries != 0) SET @TestStatus = 'Ignored'
      ELSE SET @TestStatus = 'Passed'

      IF (@ResultsFormat = 'Text')
      BEGIN
         IF (@SProcType = 'SetupS')
         BEGIN
            PRINT REPLICATE(' ', 4) + 'SESSION SETUP: ' + @TestStatus
         END
         ELSE IF (@SProcType = 'TeardownS')
         BEGIN
            PRINT REPLICATE(' ', 4) + 'SESSION TEARDOWN: ' + @TestStatus
         END
         ELSE
         BEGIN
            PRINT REPLICATE(' ', 8) + 'Test: ' + @SProcName + '. ' + @TestStatus
         END
      END
      ELSE IF (@ResultsFormat = 'XML')
      BEGIN

         IF (@SProcType = 'SetupS')
         BEGIN
            PRINT REPLICATE(' ', 4) + '<SessionSetup status="' + @TestStatus + '">'
         END
         ELSE IF (@SProcType = 'TeardownS')
         BEGIN
            PRINT REPLICATE(' ', 4) + '<SessionTeardown status="' + @TestStatus + '">'
         END
         ELSE
         BEGIN
            PRINT REPLICATE(' ', 8) + '<Test' + 
               ' name="' + @SProcName + '"' +
               ' status="' + @TestStatus + '"' +
               ' >'
         END
      END

      EXEC Internal.PrintLogEntriesForTest @TestId, @ResultsFormat, @Verbose

      IF (@ResultsFormat = 'XML')
      BEGIN
         IF (@SProcType = 'SetupS')
         BEGIN
            PRINT REPLICATE(' ', 4) + '</SessionSetup>'
         END
         ELSE IF (@SProcType = 'TeardownS')
         BEGIN
            PRINT REPLICATE(' ', 4) + '</SessionTeardown>'
         END
         ELSE
         BEGIN
            PRINT REPLICATE(' ', 8) + '</Test>'
         END
      END

      FETCH NEXT FROM CrsTestsResults INTO @TestId, @SProcType, @SProcName
   END

   CLOSE CrsTestsResults
   DEALLOCATE CrsTestsResults
   
   IF (@ResultsFormat = 'XML')
   BEGIN
      -- The session seup and session teardown are handled differently.
      IF(@SuiteTypeId != 0 AND @SuiteTypeId != 3)
      BEGIN
         PRINT REPLICATE(' ', 6) + '</Tests>'
      END
   END

END
GO
