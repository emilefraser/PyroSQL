SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[test].[TestFunction]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [test].[TestFunction] AS' 
END
GO
/*
	CREATED BY: Emile Fraser
	DATE: 2020-12-01
	DESCRIPTION: Procedure to Test Various Functions on daily basis and provides broken function names as exception

	
*/

ALTER     PROCEDURE [test].[TestFunction]
AS 
BEGIN
	DECLARE @ReturnInt INT 

	IF EXISTS (
		SELECT * FROM [balance].[GetSchemaRowCountFromPartition]('lnd', 'Landing')
	)

	SET @ReturnInt = 1


END
GO
