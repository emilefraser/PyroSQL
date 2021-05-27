SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[PrintResultsSummaryForSession]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[PrintResultsSummaryForSession] AS' 
END
GO


-- =======================================================================
-- PROCEDURE: PrintResultsSummaryForSession
-- It will print the last lines in the result screen - those that 
-- have the summary of the test session given by @TestSessionId.
-- =======================================================================
ALTER   PROCEDURE [internal].[PrintResultsSummaryForSession]
   @TestSessionId    int,         -- Identifies the test session.
   @ResultsFormat    varchar(10), -- Indicates if the format in which the results will be printed.
                                  -- See the coments at the begining of the file under section 'Results Format'
   @NoTimestamp      bit = 0      -- Indicates that no timestamp or duration info should be printed in results output
AS
BEGIN

   DECLARE @TestSessionStart              datetime
   DECLARE @TestSessionFinish             datetime
   DECLARE @TotalSuiteCount               int
   DECLARE @TotalTestCount                int
   DECLARE @TotalPassedCount              int
   DECLARE @TotalIgnoredCount             int
   DECLARE @TotalFailedCount              int

   SELECT 
      @TestSessionStart   = TestSessionStart, 
      @TestSessionFinish  = TestSessionFinish
   FROM Data.TestSession
   WHERE TestSessionId = @TestSessionId
   
   SET @TotalSuiteCount  = Internal.SFN_GetCountOfSuitesInSession(@TestSessionId) 
   SET @TotalTestCount   = Internal.SFN_GetCountOfTestsInSession(@TestSessionId) 
   SET @TotalPassedCount = Internal.SFN_GetCountOfPassedTestsInSession(@TestSessionId) 
   SET @TotalIgnoredCount= Internal.SFN_GetCountOfIgnoredTestsInSession(@TestSessionId) 
   SET @TotalFailedCount = Internal.SFN_GetCountOfFailedTestsInSession(@TestSessionId) 
   
   IF (@ResultsFormat = 'Text')
   BEGIN
      IF (@NoTimestamp = 0)
      BEGIN
         PRINT 'Start: ' + CONVERT(nvarchar(20), @TestSessionStart, 108) + '. Finish: ' + CONVERT(nvarchar(20), @TestSessionFinish, 108) + '. Duration: ' + CONVERT(nvarchar(10), DATEDIFF(ms, @TestSessionStart, @TestSessionFinish)) + ' miliseconds.'
      END

      PRINT 'Total suites: ' + CAST(@TotalSuiteCount as varchar) + '. Total tests: ' + CAST(@TotalTestCount AS varchar) + '. Test passed: ' + CAST(@TotalPassedCount AS varchar) + '. Test ignored: ' + CAST(@TotalIgnoredCount AS varchar) + '. Test failed: ' + CAST(@TotalFailedCount AS varchar) + '.'
   END

END
GO
