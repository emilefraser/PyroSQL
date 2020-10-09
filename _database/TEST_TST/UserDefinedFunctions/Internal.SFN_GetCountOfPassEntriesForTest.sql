SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- FUNCTION: SFN_GetCountOfPassEntriesForTest
-- Returns the number of log entries indicating pass for the given test.
-- =======================================================================
CREATE FUNCTION Internal.SFN_GetCountOfPassEntriesForTest(@TestId int) RETURNS int
AS 
BEGIN

   DECLARE @PassEntries int

   SELECT @PassEntries = COUNT(1) 
   FROM Data.TestLog 
   WHERE 
      TestLog.TestId = @TestId
      AND EntryType = 'P'

   RETURN ISNULL(@PassEntries, 0)

END

GO
