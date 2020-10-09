SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- VIEW: TSTResultsEx
-- Aggregates data from several tables to facilitate results reporting
-- Adds more info compared with TSTResults. Specifically test status and suite status
-- =======================================================================
CREATE VIEW Data.TSTResultsEx AS
SELECT 
   LogEntries.LogEntryId,
   LogEntries.TestSessionId,
   Suite.SuiteId,
   ISNULL(Suite.SuiteName, 'Anonymous') AS SuiteName,
   SuiteStatus = CASE WHEN SuiteFailInfo.FailuresOrErrorsCount > 0 THEN 'F' ELSE 'P' END,
   Test.TestId,
   Test.SProcName,
   TestStatus = CASE WHEN TestFailInfo.FailuresOrErrorsCount > 0 THEN 'F' ELSE 'P' END,
   LogEntries.EntryType,
   LogEntries.LogMessage,
   LogEntries.CreatedTime
FROM Data.TestLog AS LogEntries
INNER JOIN Data.Test  ON LogEntries.TestId = Test.TestId
INNER JOIN Data.Suite ON Suite.SuiteId = Test.SuiteId
INNER JOIN  (  SELECT 
                  TestId, 
                  (  SELECT COUNT(*) FROM Data.TestLog AS L1
                     WHERE 
                        (L1.EntryType = 'E' OR L1.EntryType = 'F' )
                        AND L1.TestId = T1.TestId
                  ) AS FailuresOrErrorsCount
               FROM TST.Data.Test AS T1
            ) AS TestFailInfo ON TestFailInfo.TestId = Test.TestId

INNER JOIN  (  SELECT 
                  SuiteId, 
                  (  SELECT COUNT(*) FROM Data.TestLog L2
                     INNER JOIN Data.Test AS T2 ON L2.TestId = T2.TestId 
                     WHERE 
                        (L2.EntryType = 'E' OR L2.EntryType = 'F' )
                        AND T2.SuiteId = S1.SuiteId
                  ) AS FailuresOrErrorsCount
               FROM TST.Data.Suite AS S1
            ) AS SuiteFailInfo ON SuiteFailInfo.SuiteId = Suite.SuiteId


GO
