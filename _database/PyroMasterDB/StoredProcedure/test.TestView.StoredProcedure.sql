SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[test].[TestView]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [test].[TestView] AS' 
END
GO
/*
	CREATED BY: Emile Fraser
	DATE: 2020-12-01
	DESCRIPTION: Procedure to Test Various Views on daily basis and provides broken view names as exception

	EXEC [adf].[TestView]
*/


ALTER    PROCEDURE [test].[TestView]
AS 
BEGIN
	
	
	DECLARE @ReturnInt INT 

	DECLARE 
		@SchemaName SYSNAME
	,	@ViewName	SYSNAME
	
	DECLARE 
		@sql_statement	NVARCHAR(MAX)
	,	@sql_parameter	NVARCHAR(MAX)
	,	@sql_message	NVARCHAR(MAX)
	,	@sql_crlf		NVARCHAR(2) = CHAR(13) + CHAR(10)
	,	@sql_debug		BIT = 1
	,	@sql_execute	BIT = 1
	,	@sql_log		BIT = 0
	,	@test_cursor	CURSOR

	DECLARE 
		@RC				INT

	DROP TABLE IF EXISTS ##ResultView 
	CREATE TABLE ##ResultView (SchemaName SYSNAME, ViewName SYSNAME, Result INT, ErrorMessage NVARCHAR(MAX))

	SET @test_cursor = CURSOR FOR
	SELECT 
		sch.name, vw.name
	FROM
		sys.views AS vw
	INNER JOIN 
		sys.schemas As sch
		ON sch.schema_id = vw.schema_id
	WHERE
		sch.name = 'infomart'
	AND
		SUBSTRING(vw.name, 1, 2) NOT IN ('xx', 'zz')

	OPEN @test_cursor

	FETCH NEXT FROM @test_cursor
	INTO @SchemaName, @ViewName

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		
		SET @sql_statement = 'SELECT @RC = COUNT(1) FROM ' + QUOTENAME(@SchemaName) + '.' +QUOTENAME(@ViewName)
		SET @sql_parameter = '@RC INT OUTPUT'

		IF (@sql_debug  = 1)
		BEGIN
			SET @sql_message = @sql_statement + '{{' + @sql_parameter + '}}'
			RAISERROR(@sql_message, 0, 1) WITH NOWAIT
		END

		IF (@sql_execute  = 1)
		BEGIN
			BEGIN TRY
				EXEC sp_executesql @stmt = @sql_statement, @param = @sql_parameter, @RC = @RC OUTPUT

				IF(@RC = 0)
				BEGIN
					INSERT INTO ##ResultView (SchemaName, ViewName , Result)
					SELECT @SchemaName, @ViewName, 0
				END 
				ELSE 
				BEGIN
					INSERT INTO ##ResultView (SchemaName, ViewName , Result)
					SELECT @SchemaName, @ViewName, 1
				END
			END TRY 
			BEGIN CATCH 
				INSERT INTO ##ResultView (SchemaName, ViewName , Result, ErrorMessage)
				SELECT @SchemaName, @ViewName, -1, ERROR_MESSAGE()
			END CATCH
		END

		FETCH NEXT FROM @test_cursor
		INTO @SchemaName, @ViewName

	END

	SELECT * FROM ##ResultView


END

GO
