SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- FUNCTION: SFN_GetCountOfIgnoreEntriesForTest
-- Returns the number of log entries indicating 'Ignore' for the given test.
-- =======================================================================
CREATE FUNCTION Internal.SFN_GetCountOfIgnoreEntriesForTest(@TestId int) RETURNS int
AS 
BEGIN

   DECLARE @IgnoreEntries int

   SELECT @IgnoreEntries = COUNT(1) 
   FROM Data.TestLog 
   WHERE 
      TestLog.TestId = @TestId
      AND EntryType = 'I'

   RETURN ISNULL(@IgnoreEntries, 0)

END

GO
