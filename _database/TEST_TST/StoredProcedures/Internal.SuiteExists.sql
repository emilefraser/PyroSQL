SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE SuiteExists
-- Determines if the suite with the name given by @TestName exists 
-- in the database with the name given by @TestDatabaseName.
-- =======================================================================
CREATE PROCEDURE Internal.SuiteExists
   @TestDatabaseName       sysname, 
   @SuiteName              sysname,
   @TestProcedurePrefix    varchar(100),
   @SuiteExists            bit OUT 
AS
BEGIN

   DECLARE @SqlCommand        nvarchar(1000)
   DECLARE @Params            nvarchar(100)
   DECLARE @TestInSuiteCount  int

   SET @SqlCommand = 'SELECT @TestInSuiteCountOUT = COUNT(*) ' + 
      'FROM ' + QUOTENAME(@TestDatabaseName) + '.sys.procedures ' + 
      'WHERE name LIKE ''' + @TestProcedurePrefix + @SuiteName + '#%'''

   SET @Params = '@TestInSuiteCountOUT int OUT'
   EXEC sp_executesql @SqlCommand, @Params, @TestInSuiteCountOUT=@TestInSuiteCount OUT

   SET @SuiteExists = 0
   IF (@TestInSuiteCount >= 1) SET @SuiteExists = 1

END

GO
