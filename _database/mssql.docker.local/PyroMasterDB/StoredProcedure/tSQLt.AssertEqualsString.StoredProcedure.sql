SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[AssertEqualsString]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[AssertEqualsString] AS' 
END
GO
ALTER PROCEDURE [tSQLt].[AssertEqualsString]
    @Expected NVARCHAR(MAX),
    @Actual NVARCHAR(MAX),
    @Message NVARCHAR(MAX) = ''
AS
BEGIN
    IF ((@Expected = @Actual) OR (@Actual IS NULL AND @Expected IS NULL))
      RETURN 0;

    DECLARE @Msg NVARCHAR(MAX);
    SELECT @Msg = CHAR(13)+CHAR(10)+
                  'Expected: ' + ISNULL('<'+@Expected+'>', 'NULL') +
                  CHAR(13)+CHAR(10)+
                  'but was : ' + ISNULL('<'+@Actual+'>', 'NULL');
    EXEC tSQLt.Fail @Message, @Msg;
END;
GO
