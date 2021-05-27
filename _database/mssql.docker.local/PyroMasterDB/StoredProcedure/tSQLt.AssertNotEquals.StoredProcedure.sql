SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[AssertNotEquals]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[AssertNotEquals] AS' 
END
GO

ALTER PROCEDURE [tSQLt].[AssertNotEquals]
    @Expected SQL_VARIANT,
    @Actual SQL_VARIANT,
    @Message NVARCHAR(MAX) = ''
AS
BEGIN
  IF (@Expected = @Actual)
  OR (@Expected IS NULL AND @Actual IS NULL)
  BEGIN
    DECLARE @Msg NVARCHAR(MAX);
    SET @Msg = 'Expected actual value to not ' + 
               COALESCE('equal <' + tSQLt.Private_SqlVariantFormatter(@Expected)+'>', 'be NULL') + 
               '.';
    EXEC tSQLt.Fail @Message,@Msg;
  END;
  RETURN 0;
END;


GO
