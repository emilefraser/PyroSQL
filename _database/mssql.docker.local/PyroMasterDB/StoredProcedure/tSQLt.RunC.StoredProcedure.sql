SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[RunC]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[RunC] AS' 
END
GO
ALTER PROCEDURE [tSQLt].[RunC]
AS
BEGIN
  DECLARE @TestName NVARCHAR(MAX);SET @TestName = NULL;
  DECLARE @InputBuffer NVARCHAR(MAX);
  EXEC tSQLt.Private_InputBuffer @InputBuffer = @InputBuffer OUT;
  IF(@InputBuffer LIKE 'EXEC tSQLt.RunC;--%')
  BEGIN
    SET @TestName = LTRIM(RTRIM(STUFF(@InputBuffer,1,18,'')));
  END;
  EXEC tSQLt.Run @TestName = @TestName;
END;
GO
