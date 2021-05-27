SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[ExecuteSqlAgainstDatbase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	Created By: Emile Fraser
	Date: 2020-09-26
	Description: Gets the full ObjectN ame

	Test1: SELECT [construct].[ExecuteSqlAgainstDatbase](''SELECT * FROM sys.tables'', NULL, NULL, NULL)
	Test2: SELECT [construct].[ExecuteSqlAgainstDatbase](''SELECT * FROM sys.tables'', ''PyroCustomerDB'' , NULL, NULL)
	Test3: SELECT [construct].[ExecuteSqlAgainstDatbase](''SELECT * FROM sys.tables'', NULL, ''@param1 INT'', ''@param1 = @paramval1'')
	Test4: SELECT [construct].[ExecuteSqlAgainstDatbase](''SELECT * FROM sys.tables'', ''PyroCustomerDB'', ''@param1 INT'', ''@param1 = @paramval1'')
*/
CREATE   FUNCTION [construct].[ExecuteSqlAgainstDatbase] (
	@Statement				NVARCHAR(MAX)
,	@DatabaseName			SYSNAME			= NULL
,	@ParameterDeclare		NVARCHAR(MAX)	= NULL
,	@ParameterValue			NVARCHAR(MAX)	= NULL
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE 
		@sql_statement			NVARCHAR(MAX)
	,	@sql_seperator			NVARCHAR(1)		= N''.''
    ,   @sql_message			NVARCHAR(MAX)
    ,   @sql_crlf				NVARCHAR(2) = CHAR(13) + CHAR(10)
    ,   @sql_crlf_eos			NVARCHAR(4) = REPLICATE(CHAR(13) + CHAR(10), 2)
	,	@sql_tab				NVARCHAR(1) = CHAR(9)
	,	@sql_crtab				NVARCHAR(3) = CHAR(13) + CHAR(10) + CHAR(9)

	DECLARE
		@cursor_paramvalue		CURSOR
	,	@sql_paramvalue			NVARCHAR(MAX)

	IF(ISNULL(@DatabaseName, '''') = '''')
	BEGIN
		SET @DatabaseName = (SELECT DB_NAME());
	END
	ELSE
	BEGIN
		SET @DatabaseName = REPLACE(REPLACE(@DatabaseName, '']'', ''''), ''['', '''')
	END

	-- Construct Statement 
	SET @sql_statement  = QUOTENAME(@DatabaseName) + @sql_seperator + QUOTENAME(''sys'') + @sql_seperator + QUOTENAME(''sp_executesql'') + @sql_crtab
	SET @sql_statement += ''@stmt  = '''''' + @Statement + '''''','' + @sql_crtab

	IF(@ParameterDeclare IS NOT NULL)
	BEGIN
		SET @sql_statement += ''@param = '''''' + @ParameterDeclare + '''''','' + @sql_crtab
	END

	-- If Params Exists 
	IF(@ParameterDeclare IS NOT NULL AND @ParameterValue IS NOT NULL)
	BEGIN

		SET @cursor_paramvalue = CURSOR FOR 
		SELECT Item 
		FROM string.[SplitStringWithDelimeterAndChunk](@ParameterValue, '','', 0)

		OPEN @cursor_paramvalue
		FETCH NEXT FROM @cursor_paramvalue
		INTO @sql_paramvalue

		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			SET @sql_statement += @sql_paramvalue + '','' + @sql_crtab

			FETCH NEXT FROM @cursor_paramvalue
			INTO @sql_paramvalue
		END
	END

	-- Remove trailing commad
	SET @sql_statement = SUBSTRING(@sql_statement, 1, LEN(@sql_statement) - 4)

	RETURN @sql_statement
END


--	DECLARE @exec nvarchar(max) = QUOTENAME(@db) + N''.sys.sp_executesql'',
--			@sql  nvarchar(max) = N''SELECT DB_NAME();'';

--EXEC @exec @sql;
--If you need to pass parameters, no problem:

--DECLARE @db sysname = N''db1'', @i int = 1;

--DECLARE @exec nvarchar(max) = QUOTENAME(@db) + N''.sys.sp_executesql'',
--        @sql  nvarchar(max) = N''SELECT DB_NAME(), @i;'';

--EXEC @exec @sql, N''@i int'', @i;
--If the goal is to execute some static SQL inside the chosen database, maybe you should consider storing that static SQL in a stored procedure in each database, and calling it dynamically like this:

--DECLARE @db sysname = N''db1'';

--DECLARE @exec nvarchar(max) = QUOTENAME(@db) + N''.sys.sp_executesql'',
--        @sql  nvarchar(max) = N''EXEC dbo.procedurename;'';

--EXEC @exec @sql;
--END

' 
END
GO
