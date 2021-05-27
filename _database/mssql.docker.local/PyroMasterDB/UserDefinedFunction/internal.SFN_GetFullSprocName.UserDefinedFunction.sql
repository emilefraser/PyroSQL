SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[SFN_GetFullSprocName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =======================================================================
-- FUNCTION SFN_GetFullSprocName
-- Returns the full name of the sproc identified by @TestId
-- The full name has the format: Database.Schema.Name
-- =======================================================================
CREATE   FUNCTION [internal].[SFN_GetFullSprocName](@TestId int) RETURNS nvarchar(1000)
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
   
   SET @FullSprocName = QUOTENAME(@DatabaseName) + ''.'' + QUOTENAME(ISNULL(@SchemaName, '''')) + ''.'' + QUOTENAME(@SProcName)

   RETURN @FullSprocName
   
END
' 
END
GO
