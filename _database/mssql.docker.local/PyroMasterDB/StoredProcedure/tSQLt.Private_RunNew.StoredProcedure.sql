SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_RunNew]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[Private_RunNew] AS' 
END
GO

ALTER PROCEDURE [tSQLt].[Private_RunNew]
  @TestResultFormatter NVARCHAR(MAX)
AS
BEGIN
  EXEC tSQLt.Private_RunCursor @TestResultFormatter = @TestResultFormatter, @GetCursorCallback = 'tSQLt.Private_GetCursorForRunNew';
END;
GO
