SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: SetConfiguration
-- Sets up TST parameters. Typically called by the tests in the SETUP 
-- procedure or in the TSTConfig procedures. 
-- In case of an invalid call it will raise an error and return 1
-- =======================================================================
CREATE PROCEDURE Utils.SetConfiguration
   @ParameterName       varchar(32),        -- See table TSTParameters and CK_TSTParameters_ParameterName.
   @ParameterValue      varchar(100),       -- The parameter value. Depends on the ParameterName.
                                            -- See table TSTParameters and CK_TSTParameters_ParameterName.
   @Scope               sysname,            -- See table TSTParameters and CK_TSTParameters_Scope.
   @ScopeValue          sysname = NULL      -- Depends on Scope. 
                                            -- See table TSTParameters and CK_TSTParameters_Scope.
AS
BEGIN

   DECLARE @TestSessionId           int
   DECLARE @TestDatabaseName        sysname
   DECLARE @SuiteExists             bit
   DECLARE @TestProcedurePrefix     varchar(100)

   SELECT @TestSessionId = TestSessionId FROM #Tmp_CrtSessionInfo
   SELECT @TestDatabaseName = TestSession.DatabaseName FROM Data.TestSession WHERE TestSessionId = @TestSessionId

   SELECT @TestProcedurePrefix = Internal.SFN_GetTestProcedurePrefix(@TestDatabaseName)

   IF (@ParameterName != 'UseTSTRollback')
   BEGIN
         RAISERROR('Invalid call to SetConfiguration. @ParameterName has an invalid value: ''%s''.', 16, 1, @ParameterName)
         RETURN 1
   END
   
   -- Validate parameters
   IF (@ParameterName='UseTSTRollback')
   BEGIN
      IF (@ParameterValue IS NULL OR (@ParameterValue != '0' AND @ParameterValue != '1') )
      BEGIN
         RAISERROR('Invalid call to SetConfiguration. @ParameterValue has an invalid value: ''%s''. Valid values are ''0'' and ''1''', 16, 1, @ParameterValue)
         RETURN 1
      END
   END
   
   IF (@Scope='All')
   BEGIN
      IF (@ScopeValue IS NOT NULL)
      BEGIN
         RAISERROR('Invalid call to SetConfiguration. @ScopeValue has an invalid value: ''%s''. When @Scope=''All'' @ScopeValue can only be NULL', 16, 1, @ScopeValue)
         RETURN 1
      END
   END
   ELSE IF (@Scope='Suite')
   BEGIN
      IF (@ScopeValue IS NULL)
      BEGIN
         RAISERROR('Invalid call to SetConfiguration. @ScopeValue cannot be NULL when @Scope=''Suite''', 16, 1)
         RETURN 1
      END
      
      EXEC Internal.SuiteExists @TestDatabaseName, @ScopeValue, @TestProcedurePrefix, @SuiteExists OUT
      IF (@SuiteExists = 0)
      BEGIN
         RAISERROR('Invalid call to SetConfiguration. Cannot find the suite indicated by @ScopeValue: ''%s''', 16, 1, @ScopeValue)
         RETURN 1
      END
   END
   ELSE IF (@Scope='Test')
   BEGIN
      IF (@ScopeValue IS NULL)
      BEGIN
         RAISERROR('Invalid call to SetConfiguration. @ScopeValue cannot be NULL when @Scope=''Test''', 16, 1)
         RETURN 1
      END

      IF (Internal.SFN_SProcExists(@TestDatabaseName, @ScopeValue) = 0)
      BEGIN
         RAISERROR('Invalid call to SetConfiguration. Cannot find the test indicated by @ScopeValue: ''%s''', 16, 1, @ScopeValue)
         RETURN 1
      END

      -- Make sure that the procedure given by @ScopeValue followsthe namingconvention for a TST test
      DECLARE @SuiteName         sysname
      DECLARE @IsTSTSproc        bit
      DECLARE @SProcType         varchar(10)

      EXEC Internal.AnalyzeSprocName @ScopeValue, @TestProcedurePrefix, @SuiteName OUTPUT, @IsTSTSproc OUTPUT, @SProcType OUTPUT
      IF (@IsTSTSproc = 0 OR @SProcType != 'Test')
      BEGIN
         RAISERROR('Invalid call to SetConfiguration. The test indicated by @ScopeValue: ''%s'' does not follow the naming conventions for a TST test procedure', 16, 1, @ScopeValue)
         RETURN 1
      END
      
   END
   ELSE
   BEGIN
      RAISERROR('Invalid call to SetConfiguration. Invalid value for @Scope: ''%s''', 16, 1, @Scope)
      RETURN 1
   END

   -- Now that the parameters were validated, insert a row in TSTParameters
   INSERT INTO Data.TSTParameters(TestSessionId, ParameterName, ParameterValue, Scope, ScopeValue) 
   VALUES (@TestSessionId, @ParameterName, @ParameterValue, @Scope, @ScopeValue)

END

GO
