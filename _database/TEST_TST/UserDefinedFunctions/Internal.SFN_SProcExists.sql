SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =======================================================================
-- FUNCTION SFN_SProcExists
-- Determines if the procedure with the name given by @TestName exists 
-- in database with the name given by @TestDatabaseName.
-- =======================================================================
CREATE FUNCTION Internal.SFN_SProcExists(@TestDatabaseName sysname, @SProcNameName sysname) RETURNS bit
AS
BEGIN

   DECLARE @ObjectName nvarchar(1000)
   SET @ObjectName = @TestDatabaseName + '..' + @SProcNameName

   IF (object_id(@ObjectName, 'P') IS NOT NULL)
   BEGIN
      RETURN 1
   END

   RETURN 0
END

GO
