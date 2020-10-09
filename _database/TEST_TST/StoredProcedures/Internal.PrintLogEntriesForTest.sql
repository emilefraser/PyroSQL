SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =======================================================================
-- PROCEDURE: PrintLogEntriesForTest
-- It will print the results for the given test. Called by PrintOneSuiteResults
-- =======================================================================
CREATE PROCEDURE Internal.PrintLogEntriesForTest
   @TestId          int,            -- Identifies the test.
   @ResultsFormat   varchar(10),    -- Indicates if the format in which the results will be printed.
                                    -- See the coments at the begining of the file under section 'Results Format'
   @Verbose         bit             -- If 1 then the output will contain all suites and tests names and all the log entries.
                                    -- If 0 then the output will contain all suites and tests names but only the 
                                    -- log entries indicating failures.
   
AS
BEGIN

   DECLARE @EntryType         char
   DECLARE @LogMessage        nvarchar(max)
   DECLARE @EntryTypeString   varchar(10)

   IF (@Verbose = 1)
   BEGIN
      DECLARE CrsTestResults CURSOR LOCAL FOR
      SELECT Internal.SFN_GetEntryTypeName(EntryType), LogMessage FROM Data.TSTResults
      WHERE TestId = @TestId
      ORDER BY LogEntryId
   END
   ELSE
   BEGIN
      DECLARE CrsTestResults CURSOR LOCAL FOR
      SELECT Internal.SFN_GetEntryTypeName(EntryType), LogMessage FROM Data.TSTResults
      WHERE TestId = @TestId AND EntryType IN ('F', 'E')
      ORDER BY LogEntryId
   END


   OPEN CrsTestResults
   FETCH NEXT FROM CrsTestResults INTO @EntryTypeString, @LogMessage
   WHILE @@FETCH_STATUS = 0
   BEGIN

      IF (@ResultsFormat = 'Text')
      BEGIN
         PRINT REPLICATE(' ', 12) + @EntryTypeString + ': ' + @LogMessage
      END
      ELSE IF (@ResultsFormat = 'XML')
      BEGIN
         PRINT REPLICATE(' ', 10) + '<Log entryType="' + @EntryTypeString + '">' + Internal.SFN_EscapeForXml(@LogMessage) + '</Log>'
      END

      FETCH NEXT FROM CrsTestResults INTO @EntryTypeString, @LogMessage
   END

   CLOSE CrsTestResults
   DEALLOCATE CrsTestResults

END

GO
