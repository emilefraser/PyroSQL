SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- FUNCTION: SFN_GetCountOfFailOrErrorEntriesForTest
-- Returns the number of log entries indicating failures or 
-- errors for the given test.
-- =======================================================================
CREATE FUNCTION Internal.SFN_GetCountOfFailOrErrorEntriesForTest(@TestId int) RETURNS int
AS 
BEGIN

   DECLARE @FailOrErrorEntries int

   SELECT @FailOrErrorEntries = COUNT(1) 
   FROM Data.TestLog 
   WHERE 
      TestLog.TestId = @TestId
      AND EntryType IN ('F', 'E')

   RETURN ISNULL(@FailOrErrorEntries, 0)

END

GO
