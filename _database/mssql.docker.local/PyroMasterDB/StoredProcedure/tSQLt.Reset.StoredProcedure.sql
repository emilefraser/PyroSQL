SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Reset]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[Reset] AS' 
END
GO
ALTER PROCEDURE [tSQLt].[Reset]
AS
BEGIN
  EXEC tSQLt.Private_ResetNewTestClassList;
END;
GO
