SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_GetSetupProcedureName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[Private_GetSetupProcedureName] AS' 
END
GO


ALTER PROCEDURE [tSQLt].[Private_GetSetupProcedureName]
  @TestClassId INT = NULL,
  @SetupProcName NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SELECT @SetupProcName = tSQLt.Private_GetQuotedFullName(object_id)
      FROM sys.procedures
     WHERE schema_id = @TestClassId
       AND LOWER(name) = 'setup';
END;
GO
