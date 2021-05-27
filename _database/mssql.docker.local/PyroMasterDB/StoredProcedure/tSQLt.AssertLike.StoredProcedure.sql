SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[AssertLike]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[AssertLike] AS' 
END
GO
ALTER PROCEDURE [tSQLt].[AssertLike] 
  @ExpectedPattern NVARCHAR(MAX),
  @Actual NVARCHAR(MAX),
  @Message NVARCHAR(MAX) = ''
AS
BEGIN
  IF (LEN(@ExpectedPattern) > 4000)
  BEGIN
    RAISERROR ('@ExpectedPattern may not exceed 4000 characters.', 16, 10);
  END;

  IF ((@Actual LIKE @ExpectedPattern) OR (@Actual IS NULL AND @ExpectedPattern IS NULL))
  BEGIN
    RETURN 0;
  END

  DECLARE @Msg NVARCHAR(MAX);
  SELECT @Msg = CHAR(13) + CHAR(10) + 'Expected: <' + ISNULL(@ExpectedPattern, 'NULL') + '>' +
                CHAR(13) + CHAR(10) + ' but was: <' + ISNULL(@Actual, 'NULL') + '>';
  EXEC tSQLt.Fail @Message, @Msg;
END;
GO
