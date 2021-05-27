SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[PrintResults]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[PrintResults] AS' 
END
GO

-- =======================================================================
-- PROCEDURE: PrintResults
-- It will print all the results of the current test session. 
-- =======================================================================
ALTER   PROCEDURE [internal].[PrintResults]
   @TestSessionId    int,         -- Identifies the test session.
   @ResultsFormat    varchar(10), -- Indicates if the format in which the results will be printed.
                                  -- See the coments at the begining of the file under section 'Results Format'
   @NoTimestamp      bit = 0,     -- Indicates that no timestamp or duration info should be printed in results output
   @Verbose          bit = 0      -- If 1 then the output will contain all suites and tests names and all the log entries.
                                  -- If 0 then the output will contain all suites and tests names but only the 
                                  -- log entries indicating failures.
AS
BEGIN
   
   IF (      @ResultsFormat != 'Text'
         AND @ResultsFormat != 'XML'
         AND @ResultsFormat != 'Batch'
         AND @ResultsFormat != 'None' )
   BEGIN
      RAISERROR('Invalid call to RunSuite. @TestDatabaseName cannot be NULL.', 16, 1)
      RETURN 1
   END

   IF (@ResultsFormat = 'None') RETURN 0

   IF (@ResultsFormat = 'Batch' OR @ResultsFormat = 'Text' ) PRINT ''
   
   IF (@ResultsFormat = 'Batch')
   BEGIN
      PRINT 'TST TestSessionId: ' + CAST(@TestSessionId as varchar)

      -- For the rest of the print process 'Batch' mode is the same as 'Text' mode
      SET @ResultsFormat = 'Text'
   END
   
   IF (@ResultsFormat = 'XML')
   BEGIN
      PRINT '<?xml version="1.0" encoding="utf-8" ?> '
   END

   EXEC Internal.PrintHeaderForSession         @TestSessionId, @ResultsFormat, @NoTimestamp
   EXEC Internal.PrintSystemErrorsForSession   @TestSessionId, @ResultsFormat
   EXEC Internal.PrintSuitesResultsForSession  @TestSessionId, @ResultsFormat, @Verbose

   IF (@ResultsFormat = 'Batch' OR @ResultsFormat = 'Text' ) PRINT ''
   EXEC Internal.PrintResultsSummaryForSession @TestSessionId, @ResultsFormat, @NoTimestamp

   IF (@ResultsFormat = 'Text')
   BEGIN
      PRINT ''
      EXEC Internal.PrintStatusForSession  @TestSessionId
      PRINT ''
   END
   ELSE
   IF (@ResultsFormat = 'XML')
   BEGIN
      PRINT '</TST>'
   END

   RETURN 0
END
GO
