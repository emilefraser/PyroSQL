SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[runner].[RunSuite]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [runner].[RunSuite] AS' 
END
GO


-- =======================================================================
-- END TST API.
-- =======================================================================


-- =======================================================================
-- START External trigger points.
-- These are stored procedures that can be called to trigger TST testing.
-- =======================================================================

-- =======================================================================
-- PROCEDURE: RunSuite
-- It will run all the test procedures in the database given 
-- by @TestDatabaseName and belonging to the suite given by @SuiteName.
-- If @SuiteName IS NULL then it will run all the Test suites 
-- detected in the database given by @TestDatabaseName.
-- =======================================================================
ALTER   PROCEDURE [runner].[RunSuite]
   @TestDatabaseName       sysname,                -- The database that contains the test procedures.
   @SuiteName              sysname,                -- The suite that must be run. If NULL then 
                                                   -- tests in all suites will be run.
   @Verbose                bit = 0,                -- If 1 then the output will contain all suites and tests names and all the log entries.
                                                   -- If 0 then the output will contain all suites and tests names but only the 
                                                   -- log entries indicating failures.
   @ResultsFormat          varchar(10) = 'Text',   -- Indicates if the format in which the results will be printed.
                                                   -- See the coments at the begining of the file under section 'Results Format'
   @NoTimestamp            bit = 0,                -- Indicates that no timestamp or duration info should be printed in results output
   @CleanTemporaryData     bit = 1,                -- Indicates if the temporary tables should be cleaned at the end.
   @TestSessionId          int = NULL OUT,         -- At return will identify the test session 
   @TestSessionPassed      bit = NULL OUT          -- At return will indicate if all tests passed or not.
AS
BEGIN

   DECLARE @PrepareResult           int
   DECLARE @TestProcedurePrefix     varchar(100)

   SET NOCOUNT ON

   IF (@TestDatabaseName IS NULL) 
   BEGIN
      RAISERROR('Invalid call to RunSuite. @TestDatabaseName cannot be NULL.', 16, 1)
      RETURN 1
   END      

   BEGIN
      CREATE TABLE #Tmp_CrtSessionInfo (
         TestSessionId                 int NOT NULL,
         TestId                        int NOT NULL,
         Stage                         char NOT NULL,       -- '-' Outside of any test
                                                            -- 'A' Test session setup stage
                                                            -- 'S' Setup stage
                                                            -- 'T' Test stage
                                                            -- 'X' Teardown stage
                                                            -- 'Z' Test session teardown stage
         ExpectedErrorNumber           int NULL,
         ExpectedErrorMessage          nvarchar(2048),
         ExpectedErrorProcedure        nvarchar(126),
         ExpectedErrorContextMessage   nvarchar(1000)
      )
   END
   
   EXEC @PrepareResult = Internal.PrepareTestSession @TestDatabaseName, @TestSessionId OUTPUT
   
   IF (@PrepareResult = 0)
   BEGIN
      SELECT @TestProcedurePrefix = Internal.SFN_GetTestProcedurePrefix(@TestDatabaseName)
      EXEC @PrepareResult = Internal.PrepareTestSessionInformation @TestSessionId, @TestProcedurePrefix, @TestDatabaseName, @SuiteName, NULL
      IF (@PrepareResult = 0)
      BEGIN
         EXEC Internal.RunTestSession @TestSessionId, @SuiteName
      END
   END
   
   -- Note: if @PrepareResult is 0 then we already have errors in the TestLog table.

   SET @TestSessionPassed = 1
   IF EXISTS (SELECT 1 FROM Data.TestLog WHERE TestSessionId = @TestSessionId AND EntryType IN ('F', 'E')) SET @TestSessionPassed = 0
   IF EXISTS (SELECT 1 FROM Data.SystemErrorLog WHERE TestSessionId = @TestSessionId) SET @TestSessionPassed = 0

   UPDATE Data.TestSession SET TestSessionFinish = GETDATE()
  
   EXEC Internal.PostTestRun @TestSessionId, @ResultsFormat, @NoTimestamp, @Verbose, @CleanTemporaryData
   
END
GO
