SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[runner].[RunAll]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [runner].[RunAll] AS' 
END
GO

-- =======================================================================
-- PROCEDURE: RunAll
-- It will run all the test procedures in the database given 
-- by @TestDatabaseName.
-- =======================================================================
ALTER   PROCEDURE [runner].[RunAll]
   @TestDatabaseName    sysname,                   -- The database that contains the test procedures.
   @Verbose             bit = 0,                   -- If 1 then the output will contain all suites and tests names and all the log entries.
                                                   -- If 0 then the output will contain all suites and tests names but only the 
                                                   -- log entries indicating failures.
   @ResultsFormat       varchar(10) = 'Text',      -- Indicates if the format in which the results will be printed.
                                                   -- See the coments at the begining of the file under section 'Results Format'
   @NoTimestamp         bit = 0,                   -- Indicates that no timestamp or duration info should be printed in results output
   @CleanTemporaryData  bit = 1,                   -- Indicates if the temporary tables should be cleaned at the end.
   @TestSessionId       int = NULL OUT,            -- At return will identify the test session 
   @TestSessionPassed   bit = NULL OUT             -- At return will indicate if all tests passedor not.
AS
BEGIN

   IF (@TestDatabaseName IS NULL) 
   BEGIN
      RAISERROR('Invalid call to RunAll. @TestDatabaseName cannot be NULL.', 16, 1)
      RETURN 1
   END
   
   SET NOCOUNT ON
   EXEC runner.RunSuite @TestDatabaseName, NULL,  @Verbose, @ResultsFormat, @NoTimestamp, @CleanTemporaryData, @TestSessionId OUT, @TestSessionPassed OUT
END
GO
