SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[template].[FailProcedure]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [template].[FailProcedure] AS' 
END
GO
ALTER PROCEDURE [template].[FailProcedure]
	(
	@RaiseError VARCHAR(50)
	)
AS
BEGIN
	IF(@RaiseError = 'true')
	BEGIN
		RAISERROR('The Stored Procedure intentionally failed.',16,1);
		RETURN 0;
	END
END;
GO
