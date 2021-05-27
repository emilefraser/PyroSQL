SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[SFN_GetEntryTypeName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

-- =======================================================================
-- FUNCTION SFN_GetEntryTypeName
-- Returns the name corresponding to the @EntryType. See TestLog.EntryType
-- =======================================================================
CREATE   FUNCTION [internal].[SFN_GetEntryTypeName](@EntryType char) RETURNS varchar(10)
AS
BEGIN

   IF @EntryType = ''P'' RETURN ''Pass''
   IF @EntryType = ''I'' RETURN ''Ignore''
   IF @EntryType = ''L'' RETURN ''Log''
   IF @EntryType = ''F'' RETURN ''Failure''
   IF @EntryType = ''E'' RETURN ''Error''

   RETURN ''???''
   
END
' 
END
GO
