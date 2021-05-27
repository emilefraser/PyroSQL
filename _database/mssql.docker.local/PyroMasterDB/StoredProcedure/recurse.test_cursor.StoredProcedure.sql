SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[recurse].[test_cursor]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [recurse].[test_cursor] AS' 
END
GO

ALTER   PROCEDURE [recurse].[test_cursor]
AS
BEGIN
	DECLARE
		@cur        CURSOR
	,	@name        SYSNAME

	EXEC [obj_cursor]
		 @obj_cursor = @cur OUTPUT

	FETCH NEXT FROM @cur 
	INTO @name
	WHILE @@FETCH_STATUS = 0

	BEGIN

		PRINT @name

		FETCH NEXT FROM @cur 
		INTO @name

	END

	CLOSE @cur

	DEALLOCATE @cur
END
GO
