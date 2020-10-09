SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE PrepareTestSessionSetupInformation 
-- Analyses the given database and prepares the information needed 
-- relating to the test session setup procedure.
-- Return code:
--    0 - OK. No test session setup procedure was found or one test session setup procedure was found.
--    1 - An error was detected. For example there are two test session setup procedures in different schemas.
-- =======================================================================
CREATE PROCEDURE Internal.PrepareTestSessionSetupInformation
   @TestSessionId          int,              -- Identifies the test session.
   @TestProcedurePrefix    varchar(100)      -- The prefix used to identify the test stored procedures
AS
BEGIN

   DECLARE @SuiteId                          int
   DECLARE @TestSessionSetupProceduresCount  int
   DECLARE @SchemaName                       sysname
   DECLARE @SessionSetupProcedureName        sysname

   SET @SessionSetupProcedureName = @TestProcedurePrefix + 'SESSION_SETUP'

   SELECT @TestSessionSetupProceduresCount = COUNT(*) FROM #Tmp_Procedures WHERE SProcName = @SessionSetupProcedureName
   IF(@TestSessionSetupProceduresCount = 0) RETURN 0
   IF(@TestSessionSetupProceduresCount > 1)
   BEGIN
      DECLARE @ErrorMessage varchar(1000)
      SET @ErrorMessage = 'You cannot define more than one test session setup procedures [' + @SessionSetupProcedureName + '].'
      EXEC Internal.LogErrorMessage @ErrorMessage
      RETURN 1
   END

   SELECT @SchemaName = SchemaName FROM #Tmp_Procedures WHERE SProcName = @SessionSetupProcedureName

   EXEC Internal.EnsureSuite @TestSessionId, @SchemaName, '#SessionSetup#', @SuiteId OUTPUT
   INSERT INTO Data.Test(TestSessionId, SuiteId, SchemaName, SProcName, SProcType) VALUES (@TestSessionId, @SuiteId, @SchemaName, @SessionSetupProcedureName, 'SetupS')

   RETURN 0

END

GO
