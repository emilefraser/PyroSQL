SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[SFN_GetCountOfFailOrErrorEntriesForTest]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =======================================================================
-- FUNCTION: SFN_GetCountOfFailOrErrorEntriesForTest
-- Returns the number of log entries indicating failures or 
-- errors for the given test.
-- =======================================================================
CREATE   FUNCTION [internal].[SFN_GetCountOfFailOrErrorEntriesForTest](@TestId int) RETURNS int
AS 
BEGIN

   DECLARE @FailOrErrorEntries int

   SELECT @FailOrErrorEntries = COUNT(1) 
   FROM Data.TestLog 
   WHERE 
      TestLog.TestId = @TestId
      AND EntryType IN (''F'', ''E'')

   RETURN ISNULL(@FailOrErrorEntries, 0)

END
' 
END
GO
