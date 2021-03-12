SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[test].[VerifyIfObjectExists]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [test].[VerifyIfObjectExists] AS' 
END
GO

ALTER   PROCEDURE [test].[VerifyIfObjectExists]
AS
BEGIN

	IF OBJECT_ID('dbo.Model', 'U') IS NOT NULL
	BEGIN
		PRINT ('Do Nothing')
	END

	ELSE
	BEGIN

		CREATE TABLE dbo.Model (
			ID INT IDENTITY (1, 1)
		)

	END

END
GO
