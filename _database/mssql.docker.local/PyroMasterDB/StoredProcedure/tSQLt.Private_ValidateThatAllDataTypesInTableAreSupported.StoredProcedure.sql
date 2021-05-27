SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_ValidateThatAllDataTypesInTableAreSupported]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[Private_ValidateThatAllDataTypesInTableAreSupported] AS' 
END
GO
ALTER PROCEDURE [tSQLt].[Private_ValidateThatAllDataTypesInTableAreSupported]
 @ResultTable NVARCHAR(MAX),
 @ColumnList NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRY
      EXEC('DECLARE @EatResult INT; SELECT @EatResult = COUNT(1) FROM ' + @ResultTable + ' GROUP BY ' + @ColumnList + ';');
    END TRY
    BEGIN CATCH
      RAISERROR('The table contains a datatype that is not supported for tSQLt.AssertEqualsTable. Please refer to http://tsqlt.org/user-guide/assertions/assertequalstable/ for a list of unsupported datatypes.',16,10);
    END CATCH
END;
GO
