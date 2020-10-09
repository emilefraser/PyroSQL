SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =======================================================================
-- FUNCTION SFN_UseTSTRollbackForTest
-- Determins if transactions can be used for the given test.
-- =======================================================================
CREATE FUNCTION Internal.SFN_UseTSTRollbackForTest(@TestSessionId int, @TestId int) RETURNS bit
AS
BEGIN

   DECLARE @UseTSTRollback varchar(100)
   
   SET @UseTSTRollback = '1' -- Default value

   SELECT @UseTSTRollback = TSTParameters.ParameterValue
   FROM Data.TSTParameters 
   WHERE 
      TestSessionId = @TestSessionId
      AND ParameterName  = 'UseTSTRollback'
      AND Scope = 'All'

   -- The 'Suite' scope will overwrite the 'All' scope
   SELECT @UseTSTRollback = TSTParameters.ParameterValue
   FROM Data.TSTParameters
   INNER JOIN Data.Suite ON 
      Suite.TestSessionId = TSTParameters.TestSessionId
      AND TSTParameters.Scope = 'Suite'
      AND Suite.SuiteName = TSTParameters.ScopeValue
   INNER JOIN Data.Test ON 
      Test.SuiteId = Suite.SuiteId
   WHERE 
      TSTParameters.TestSessionId = @TestSessionId
      AND TSTParameters.ParameterName  = 'UseTSTRollback'
      AND Test.TestId = @TestId

   -- The 'Test' scope will overwrite the 'Suite' and 'All' scope
   SELECT @UseTSTRollback = TSTParameters.ParameterValue
   FROM Data.TSTParameters
   INNER JOIN Data.Test ON 
      Test.TestSessionId = TSTParameters.TestSessionId
      AND TSTParameters.Scope = 'Test'
      AND Test.SProcName = TSTParameters.ScopeValue
   WHERE 
      TSTParameters.TestSessionId = @TestSessionId
      AND TSTParameters.ParameterName  = 'UseTSTRollback'
      AND Test.TestId = @TestId
      
   IF @UseTSTRollback = '0' RETURN 0
   RETURN 1
   
END

GO
