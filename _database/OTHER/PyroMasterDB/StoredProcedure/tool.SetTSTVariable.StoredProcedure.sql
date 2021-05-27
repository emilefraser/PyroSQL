SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tool].[SetTSTVariable]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tool].[SetTSTVariable] AS' 
END
GO

-- =======================================================================
-- END TST Internals.
-- =======================================================================

-- =======================================================================
-- START TST API.
-- These are stored procedures that are typicaly called from within the 
-- test stored procedures.
-- =======================================================================

-- =======================================================================
-- PROCEDURE SetTSTVariable
-- Sets a TST variable.
-- =======================================================================
ALTER   PROCEDURE [tool].[SetTSTVariable]
   @TestDatabaseName    sysname, 
   @TSTVariableName     varchar(32),
   @TSTVariableValue    varchar(100)
AS
BEGIN

   IF EXISTS (SELECT * FROM Data.TSTVariables WHERE (DatabaseName=@TestDatabaseName OR (DatabaseName IS NULL AND @TestDatabaseName IS NULL)) AND VariableName=@TSTVariableName)
   BEGIN
      UPDATE Data.TSTVariables SET VariableValue=@TSTVariableValue
      WHERE (DatabaseName=@TestDatabaseName OR (DatabaseName IS NULL AND @TestDatabaseName IS NULL)) AND VariableName=@TSTVariableName
   END
   ELSE
   BEGIN
      INSERT INTO Data.TSTVariables(DatabaseName, VariableName, VariableValue) VALUES (@TestDatabaseName, @TSTVariableName, @TSTVariableValue)
   END

END
GO
