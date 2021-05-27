SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_RemoveSchemaBinding]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[Private_RemoveSchemaBinding] AS' 
END
GO
ALTER PROCEDURE [tSQLt].[Private_RemoveSchemaBinding]
  @object_id INT
AS
BEGIN
  DECLARE @cmd NVARCHAR(MAX);
  SELECT @cmd = tSQLt.[Private]::GetAlterStatementWithoutSchemaBinding(SM.definition)
    FROM sys.sql_modules AS SM
   WHERE SM.object_id = @object_id;
   EXEC(@cmd);
END;
GO
