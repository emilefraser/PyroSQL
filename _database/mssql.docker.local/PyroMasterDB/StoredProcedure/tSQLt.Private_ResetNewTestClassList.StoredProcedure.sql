SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_ResetNewTestClassList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[Private_ResetNewTestClassList] AS' 
END
GO


	ALTER PROCEDURE [tSQLt].[Private_ResetNewTestClassList]
	AS
	BEGIN
	  SET NOCOUNT ON;
	  DELETE FROM tSQLt.Private_NewTestClassList;
	END;
GO
