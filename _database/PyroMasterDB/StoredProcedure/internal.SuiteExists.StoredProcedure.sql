SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[SuiteExists]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[SuiteExists] AS' 
END
GO

-- =======================================================================
-- PROCEDURE SuiteExists
-- Determines if the suite with the name given by @TestName exists 
-- in the database with the name given by @TestDatabaseName.
-- =======================================================================
ALTER   PROCEDURE [internal].[SuiteExists]
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
