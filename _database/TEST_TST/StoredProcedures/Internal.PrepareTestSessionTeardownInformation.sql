SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE PrepareTestSessionTeardownInformation
-- Analyses the given database and prepares the information needed 
-- relating to the test session teardown procedure.
-- Return code:
--    0 - OK. No test session teardown procedure was found or one test session teardown procedure was found.
--    1 - An error was detected. For example there are two test session teardown procedures in different schemas.
-- =======================================================================
CREATE PROCEDURE Internal.PrepareTestSessionTeardownInformation
   @TestSessionId          int,           -- Identifies the test session.
   @TestProcedurePrefix    varchar(100)   -- The prefix used to identify the test stored procedures
AS
BEGIN

   DECLARE @SuiteId                                int
   DECLARE @TestSessionTeardownProceduresCount     int
   DECLARE @SchemaName                             sysname
   DECLARE @SessionTeardownProcedureName           sysname

   SET @SessionTeardownProcedureName = @TestProcedurePrefix + 'SESSION_TEARDOWN'

   SELECT @TestSessionTeardownProceduresCount = COUNT(*) FROM #Tmp_Procedures WHERE SProcName = @SessionTeardownProcedureName
   IF(@TestSessionTeardownProceduresCount = 0) RETURN 0
   IF(@TestSessionTeardownProceduresCount > 1)
   BEGIN
      DECLARE @ErrorMessage varchar(1000)
      SET @ErrorMessage = 'You cannot define more than one test session teardown procedures [' + @SessionTeardownProcedureName + '].'
      EXEC Internal.LogErrorMessage @ErrorMessage
      RETURN 1
   END

   SELECT @SchemaName = SchemaName FROM #Tmp_Procedures WHERE SProcName = @SessionTeardownProcedureName

   EXEC Internal.EnsureSuite @TestSessionId, @SchemaName, '#SessionTeardown#', @SuiteId OUTPUT
   INSERT INTO Data.Test(TestSessionId, SuiteId, SchemaName, SProcName, SProcType) VALUES (@TestSessionId, @SuiteId, @SchemaName, @SessionTeardownProcedureName, 'TeardownS')

   RETURN 0

END

GO
