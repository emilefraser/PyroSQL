SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_MarkSchemaAsTestClass]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[Private_MarkSchemaAsTestClass] AS' 
END
GO

ALTER PROCEDURE [tSQLt].[Private_MarkSchemaAsTestClass]
  @QuotedClassName NVARCHAR(MAX)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @UnquotedClassName NVARCHAR(MAX);

  SELECT @UnquotedClassName = name
    FROM sys.schemas
   WHERE QUOTENAME(name) = @QuotedClassName;

  EXEC sp_addextendedproperty @name = N'tSQLt.TestClass', 
                              @value = 1,
                              @level0type = 'SCHEMA',
                              @level0name = @UnquotedClassName;

  INSERT INTO tSQLt.Private_NewTestClassList(ClassName)
  SELECT @UnquotedClassName
   WHERE NOT EXISTS
             (
               SELECT * 
                 FROM tSQLt.Private_NewTestClassList AS NTC
                 WITH(UPDLOCK,ROWLOCK,HOLDLOCK)
                WHERE NTC.ClassName = @UnquotedClassName
             );
END;


GO
