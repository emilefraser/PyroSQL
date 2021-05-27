SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[SFN_GetCountOfPassEntriesForTest]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =======================================================================
-- FUNCTION: SFN_GetCountOfPassEntriesForTest
-- Returns the number of log entries indicating pass for the given test.
-- =======================================================================
CREATE   FUNCTION [internal].[SFN_GetCountOfPassEntriesForTest](@TestId int) RETURNS int
AS 
BEGIN

   DECLARE @PassEntries int

   SELECT @PassEntries = COUNT(1) 
   FROM Data.TestLog 
   WHERE 
      TestLog.TestId = @TestId
      AND EntryType = ''P''

   RETURN ISNULL(@PassEntries, 0)

END
' 
END
GO
