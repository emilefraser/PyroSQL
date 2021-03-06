USE tempdb
GO

CREATE OR ALTER PROCEDURE [obj_cursor]
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

CREATE OR ALTER PROCEDURE [test_cursor]
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

EXEC
	[test_cursor]
GO

DROP PROC
	[obj_cursor]
GO

DROP PROC
	[test_cursor]
GO