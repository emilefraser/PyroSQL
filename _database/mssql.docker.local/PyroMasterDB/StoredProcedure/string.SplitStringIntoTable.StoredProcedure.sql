SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[SplitStringIntoTable]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [string].[SplitStringIntoTable] AS' 
END
GO
/*
	DECLARE @cursor_table CURSOR 
	EXEC [string].[SplitStringIntoTable]
					@StringToSplit			= 'schema.table|schema1.table1|schema2.table2|schema3.table3'
				,	@EndOfLineCharcter		= '|'
				,	@cursor_table			= @cursor_table OUTPUT	
*/
ALTER   PROCEDURE [string].[SplitStringIntoTable]
	@StringToSplit			NVARCHAR(MAX)
,	@EndOfLineCharcter		NCHAR(1)
,	@cursor_table			CURSOR VARYING OUTPUT
AS
BEGIN

-- CREATE A TABLE TYPE
IF TYPE_ID(N'SplitStringType') IS NULL
BEGIN
CREATE TYPE SplitStringType AS TABLE (
    ID				INT IDENTITY(1,1)
,	StringValue		VARCHAR(500)
)
END

DECLARE 
	@ColumnDelimeter	NCHAR	= '.'
,	@Headers			NVARCHAR(MAX)

-- SELECT * FROM STRING_SPLIT(@StringToSplit, @EndOfLineCharcter)
DECLARE @headertable TABLE (
    ID			INT IDENTITY(1,1)
,	HeaderValue VARCHAR(500)
)

-- SELECT * FROM STRING_SPLIT(@StringToSplit, @EndOfLineCharcter)
--DECLARE @splitstringtable TABLE (
--    ID			INT IDENTITY(1,1)
--,	StringValue VARCHAR(500)
--)

DECLARE @splitstringtable SplitStringType
DECLARE @resultstringtable SplitStringType


--INSERT INTO #TblName VALUES ('schema.table'),('schema1.table1'),('schema2.table2'),('schema3.table3')
INSERT INTO @splitstringtable (StringValue)
SELECT [value] FROM STRING_SPLIT(@StringToSplit, @EndOfLineCharcter) 

--SELECT * FROM @splitstringtable

DECLARE	@NumberOfWords		INT		= (SELECT TOP 1 ISNULL(LEN([StringValue]) - LEN(REPLACE([StringValue], @ColumnDelimeter ,'')) +  1, 0) FROM @splitstringtable)
--SELECT @NumberOfWords AS NumberOfWords

INSERT INTO @headertable (HeaderValue)
SELECT PARSENAME(StringValue, @NumberOfWords)
FROM @splitstringtable
WHERE ID = 1

INSERT INTO @headertable (HeaderValue)
SELECT PARSENAME(StringValue, @NumberOfWords - 1)
FROM @splitstringtable
WHERE ID = 1

INSERT INTO @headertable (HeaderValue)
SELECT PARSENAME(StringValue, @NumberOfWords - 2)
FROM @splitstringtable
WHERE ID = 1

INSERT INTO @headertable (HeaderValue)
SELECT PARSENAME(StringValue, @NumberOfWords - 3)
FROM @splitstringtable
WHERE ID = 1

INSERT INTO @headertable (HeaderValue)
SELECT PARSENAME(StringValue, @NumberOfWords - 4)
FROM @splitstringtable
WHERE ID = 1

--SELECT * FROM @headertable

--SET @NumberOfWords += 1

DECLARE @i INT = 1
DECLARE @sql_statement NVARCHAR(MAX)
,	 @sql_parameter NVARCHAR(MAX)

SET @sql_statement = '
	SET @cursor_table = CURSOR FORWARD_ONLY STATIC FOR
	SELECT
	     vallist.*
	FROM
		@splitstringtable AS t 
	CROSS APPLY (
		SELECT '

--PRINT(@sql_statement)

WHILE @i <= @NumberOfWords
BEGIN
    SET @sql_statement = @sql_statement
             + IIF(@i > 1,', ','') -- First row
			 + CONVERT(SYSNAME, QUOTENAME((SELECT HeaderValue FROM  @headertable WHERE ID = (@i))))
			 + ' = x.value (''/x[' + CAST(@I AS NVARCHAR(MAX)) + ']'',''varchar(max)'')'

	--SELECT QUOTENAME((SELECT HeaderValue FROM  @headertable WHERE ID = (@i)))
	--PRINT(@sql_statement) 
    SET @i = @i + 1
END
--PRINT(@sql_statement) 

SET @sql_statement = @sql_statement + '
       FROM
          (SELECT CAST(''<x>'' + REPLACE(StringValue,''.'',''</x><x>'') + ''</x>'' as XML) x) a
    ) AS vallist'

	--PRINT(@sql_statement)

SET @sql_statement = @sql_statement + '
		WHERE t.Id > 1' + CHAR(13) + CHAR(10) 
			--PRINT(@sql_statement)

SET @sql_statement = @sql_statement + '
		OPEN @cursor_table'

--PRINT(@sql_statement)


SET @sql_parameter = '@splitstringtable SplitStringType READONLY, @cursor_table CURSOR OUTPUT' 

PRINT(@sql_statement)

EXECUTE sp_executesql 
			@stmt				= @sql_statement
		,	@param				= @sql_parameter
		,	@splitstringtable	= @splitstringtable
		,	@cursor_table		= @cursor_table OUTPUT


--		DECLARE @a NVARCHAR(MAX), @b NVARCHAR(MAX)
	
--	--OPEN  @cursor_table
--	FETCH NEXT FROM  @cursor_table
--	INTO @a , @b



--WHILE (@@FETCH_STATUS = 0 )

--BEGIN


--	SELECT @a , @b

--FETCH NEXT FROM  @cursor_table
--INTO @a , @b

--END



END
GO
