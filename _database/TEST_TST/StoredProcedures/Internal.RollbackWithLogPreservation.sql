SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE RollbackWithLogPreservation
-- Rollbacks a transaction but makes sure that the entries in the log 
-- table TestLog are preserved.
-- =======================================================================
CREATE PROCEDURE Internal.RollbackWithLogPreservation
   @TestSessionId                   int,        -- Identifies the test session.
   @LastTestLogEntryIdBeforeTest    int         -- The last id that was present in the TestLog 
                                                -- table before the test execution started.
AS
BEGIN

   DECLARE @LastTestLogEntryIdAfterRollback  int

   -- @TempLogEntries will temporarily save the log entries that will dissapear due to the ROLLBACK
   DECLARE @TempLogEntries TABLE (
      LogEntryId     int NOT NULL,
      TestSProcId    int NOT NULL,
      EntryType      char NOT NULL,
      CreatedTime    DateTime NOT NULL,
      LogMessage     nvarchar(max) NOT NULL
   )

   DELETE FROM @TempLogEntries
   
   INSERT INTO @TempLogEntries(LogEntryId, TestSProcId, EntryType, CreatedTime, LogMessage) 
   SELECT LogEntryId, TestId, EntryType, CreatedTime, LogMessage 
   FROM Data.TestLog
   WHERE 
      LogEntryId > @LastTestLogEntryIdBeforeTest
      AND TestSessionId = @TestSessionId


   ROLLBACK TRANSACTION

   -- Determine which entries from TestLog did not survived
   SELECT @LastTestLogEntryIdAfterRollback = LogEntryId FROM Data.TestLog WHERE TestSessionId = @TestSessionId
   SET @LastTestLogEntryIdAfterRollback = ISNULL(@LastTestLogEntryIdAfterRollback, 0)

   -- Put back in table TestLog the entries that were lost due to the ROLLBACK 
   INSERT INTO Data.TestLog (TestSessionId, TestId, EntryType, CreatedTime, LogMessage)
   SELECT @TestSessionId, TestSProcId, EntryType, CreatedTime, LogMessage
   FROM @TempLogEntries
   WHERE LogEntryId > @LastTestLogEntryIdAfterRollback
   ORDER BY CreatedTime

END


GO
