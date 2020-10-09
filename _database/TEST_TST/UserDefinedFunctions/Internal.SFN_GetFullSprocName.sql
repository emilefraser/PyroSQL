SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- FUNCTION SFN_GetFullSprocName
-- Returns the full name of the sproc identified by @TestId
-- The full name has the format: Database.Schema.Name
-- =======================================================================
CREATE FUNCTION Internal.SFN_GetFullSprocName(@TestId int) RETURNS nvarchar(1000)
AS
BEGIN

   DECLARE @DatabaseName   sysname
   DECLARE @SchemaName     sysname
   DECLARE @SProcName      sysname
   DECLARE @FullSprocName  nvarchar(1000)

   SELECT 
      @DatabaseName  = TestSession.DatabaseName,
      @SchemaName    = Test.SchemaName,
      @SProcName     = Test.SProcName
   FROM Data.Test
   INNER JOIN Data.TestSession ON TestSession.TestSessionId = Test.TestSessionId
   WHERE TestId = @TestId
   
   SET @FullSprocName = QUOTENAME(@DatabaseName) + '.' + QUOTENAME(ISNULL(@SchemaName, '')) + '.' + QUOTENAME(@SProcName)

   RETURN @FullSprocName
   
END

GO
