SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =======================================================================
-- FUNCTION SFN_GetEntryTypeName
-- Returns the name corresponding to the @EntryType. See TestLog.EntryType
-- =======================================================================
CREATE FUNCTION Internal.SFN_GetEntryTypeName(@EntryType char) RETURNS varchar(10)
AS
BEGIN

   IF @EntryType = 'P' RETURN 'Pass'
   IF @EntryType = 'I' RETURN 'Ignore'
   IF @EntryType = 'L' RETURN 'Log'
   IF @EntryType = 'F' RETURN 'Failure'
   IF @EntryType = 'E' RETURN 'Error'

   RETURN '???'
   
END

GO
