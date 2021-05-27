SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_ValidateFakeTableParameters]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[Private_ValidateFakeTableParameters] AS' 
END
GO

ALTER PROCEDURE [tSQLt].[Private_ValidateFakeTableParameters]
  @SchemaName NVARCHAR(MAX),
  @OrigTableName NVARCHAR(MAX),
  @OrigSchemaName NVARCHAR(MAX)
AS
BEGIN
   IF @SchemaName IS NULL
   BEGIN
        DECLARE @FullName NVARCHAR(MAX); SET @FullName = @OrigTableName + COALESCE('.' + @OrigSchemaName, '');
        
        RAISERROR ('FakeTable could not resolve the object name, ''%s''. (When calling tSQLt.FakeTable, avoid the use of the @SchemaName parameter, as it is deprecated.)', 
                   16, 10, @FullName);
   END;
END;


GO
