SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Run]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[Run] AS' 
END
GO

ALTER PROCEDURE [tSQLt].[Run]
   @TestName NVARCHAR(MAX) = NULL,
   @TestResultFormatter NVARCHAR(MAX) = NULL
AS
BEGIN
  EXEC tSQLt.Private_RunMethodHandler @RunMethod = 'tSQLt.Private_Run', @TestResultFormatter = @TestResultFormatter, @TestName = @TestName; 
END;
GO
