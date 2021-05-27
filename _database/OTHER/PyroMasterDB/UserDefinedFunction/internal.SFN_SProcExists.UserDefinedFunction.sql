SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[SFN_SProcExists]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

-- =======================================================================
-- FUNCTION SFN_SProcExists
-- Determines if the procedure with the name given by @TestName exists 
-- in database with the name given by @TestDatabaseName.
-- =======================================================================
CREATE   FUNCTION [internal].[SFN_SProcExists](@TestDatabaseName sysname, @SProcNameName sysname) RETURNS bit
AS
BEGIN

   DECLARE @ObjectName nvarchar(1000)
   SET @ObjectName = @TestDatabaseName + ''..'' + @SProcNameName

   IF (object_id(@ObjectName, ''P'') IS NOT NULL)
   BEGIN
      RETURN 1
   END

   RETURN 0
END
' 
END
GO
