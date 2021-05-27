SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[SFN_GetCountOfIgnoreEntriesForTest]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =======================================================================
-- FUNCTION: SFN_GetCountOfIgnoreEntriesForTest
-- Returns the number of log entries indicating ''Ignore'' for the given test.
-- =======================================================================
CREATE   FUNCTION [internal].[SFN_GetCountOfIgnoreEntriesForTest](@TestId int) RETURNS int
AS 
BEGIN

   DECLARE @IgnoreEntries int

   SELECT @IgnoreEntries = COUNT(1) 
   FROM Data.TestLog 
   WHERE 
      TestLog.TestId = @TestId
      AND EntryType = ''I''

   RETURN ISNULL(@IgnoreEntries, 0)

END
' 
END
GO
