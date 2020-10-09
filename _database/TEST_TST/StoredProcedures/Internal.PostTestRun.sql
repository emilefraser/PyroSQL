SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: PostTestRun
-- Execute the optional post test run steps: print results and 
-- clean of temporary data.
-- =======================================================================
CREATE PROCEDURE Internal.PostTestRun
   @TestSessionId          int,              -- Identifies the test session.
   @ResultsFormat          varchar(10),      -- Indicates if the format in which the results will be printed.
                                             -- See the coments at the begining of the file under section 'Results Format'
   @NoTimestamp            bit,              -- Indicates that no timestamp or duration info should be printed in results output
   @Verbose                bit,              -- If 1 then the output will contain all suites and tests names and all the log entries.
                                             -- If 0 then the output will contain all suites and tests names but only the 
                                             -- log entries indicating failures.
   @CleanTemporaryData     bit               -- Indicates if the temporary tables should be cleaned at the end.
AS
BEGIN

   EXEC Internal.PrintResults @TestSessionId, @ResultsFormat, @NoTimestamp, @Verbose
   IF (@CleanTemporaryData = 1)  EXEC Internal.CleanSessionData  @TestSessionId
   
END

GO
