SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- VIEW: TSTResults 
-- Aggregates data from several tables to facilitate results reporting
-- =======================================================================
CREATE VIEW Data.TSTResults AS
SELECT 
   TestLog.LogEntryId,
   TestLog.TestSessionId,
   Suite.SuiteId,
   Suite.SuiteName,
   Test.TestId,
   Test.SProcName,
   Test.SProcType,
   TestLog.EntryType,
   TestLog.CreatedTime,
   TestLog.LogMessage
FROM Data.TestLog
INNER JOIN Data.Test  ON TestLog.TestId = Test.TestId
INNER JOIN Data.Suite ON Suite.SuiteId = Test.SuiteId


GO
