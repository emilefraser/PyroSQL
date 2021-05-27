SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[recurse].[obj_cursor]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [recurse].[obj_cursor] AS' 
END
GO
ALTER   PROCEDURE [recurse].[obj_cursor]
	@obj_cursor        CURSOR VARYING OUTPUT
AS
BEGIN

	SET @obj_cursor = CURSOR FORWARD_ONLY STATIC FOR 
	SELECT TOP 10
			[name]
		FROM
			[sys].[objects]
		WHERE
			is_ms_shipped = 0

	OPEN @obj_cursor
END
GO
