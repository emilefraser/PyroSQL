SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[AnalyzeSprocName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[AnalyzeSprocName] AS' 
END
GO

-- =======================================================================
-- PROCEDURE AnalyzeSprocName
-- Analyses the given stored procedure. Detects if it is TST procedure
-- and returns to the caller info needed to categorize it.
-- =======================================================================
ALTER   PROCEDURE [internal].[AnalyzeSprocName]
   @SProcName              sysname,             -- The name of the stored procedure.
   @TestProcedurePrefix    varchar(100),        -- The prefix used to identify the test stored procedures
   @SuiteName              sysname OUTPUT,      -- At return it will be the suite name.
   @IsTSTSproc             bit OUTPUT,          -- At return it will indicate if it is a TST procedure.
   @SProcType              varchar(10) OUTPUT   -- At return it will indicate the type of TST procedure.
                                          -- See Data.Test.SProcType
AS
BEGIN

   DECLARE @TestNameIndex int

   SET @IsTSTSproc  = 0

   IF( CHARINDEX(@TestProcedurePrefix, @SProcName) != 1)   
   BEGIN
      -- This is not a SQL Test sproc
      RETURN 0
   END

   SET @IsTSTSproc = 1
   
   -- Remove the prefix from @SProcName.
   SET @SProcName = RIGHT(@SProcName, LEN(@SProcName) - LEN(@TestProcedurePrefix))
   
   IF( CHARINDEX('SETUP_', @SProcName) = 1)
   BEGIN
      SET @SProcType = 'Setup'
      SET @SuiteName = RIGHT(@SProcName, LEN(@SProcName) - 6)
      RETURN 0
   END
   
   IF( CHARINDEX('TEARDOWN_', @SProcName) = 1)
   BEGIN
      SET @SProcType = 'Teardown'
      SET @SuiteName = RIGHT(@SProcName, LEN(@SProcName) - 9)
      RETURN 0
   END
   
   SET @TestNameIndex = CHARINDEX('#', @SProcName)
   IF( @TestNameIndex != 0)
   BEGIN
      SET @SProcType = 'Test'
      SET @SuiteName = LEFT(@SProcName, @TestNameIndex - 1)
      RETURN 0
   END

   -- This test is not associated with a specific suite.
   SET @SuiteName = NULL
   SET @SProcType = 'Test'

   RETURN 0
   
END
GO
