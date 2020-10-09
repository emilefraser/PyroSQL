SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =======================================================================
-- FUNCTION SFN_GetTestProcedurePrefix
-- Returns the prefix used to identify test procedures 
-- for the given test database.
-- This prefix can be customized in table Data.TSTVariables.
-- By default this is "SQLTest_".
-- =======================================================================
CREATE FUNCTION Internal.SFN_GetTestProcedurePrefix(@TestDatabaseName sysname) RETURNS varchar(32)
AS
BEGIN

   DECLARE @TestProcedurePrefix     varchar(100)

   -- Set @TestProcedurePrefix to its default value in case none is specified in the table Data.TSTVariables.
   SET @TestProcedurePrefix = 'SQLTest_'

   -- Overwrite @TestProcedurePrefix with the value specified in Data.TSTVariables for the global scope.
   SELECT @TestProcedurePrefix = VariableValue
   FROM Data.TSTVariables
   WHERE 
      DatabaseName IS NULL 
      AND VariableName  = 'SqlTestPrefix' 

   -- Overwrite @TestProcedurePrefix with the value specified in Data.TSTVariables for the given test database.
   SELECT @TestProcedurePrefix = VariableValue
   FROM Data.TSTVariables
   WHERE 
      DatabaseName = @TestDatabaseName
      AND VariableName  = 'SqlTestPrefix' 

   RETURN @TestProcedurePrefix
   
END

GO
