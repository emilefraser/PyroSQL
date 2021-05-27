SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[ImportFlatFileRow]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[ImportFlatFileRow] AS' 
END
GO
/*
{{META>}}
	{Written By}	Emile Fraser
	{CreatedDate}	2021-01-22
	{UpdatedDate}	2021-01-22
	{Description}	Splits a row from a flat file and import into specified table

	{Usage>}		
					EXEC [inout].[ImportFlatFileRow]
							@RowValue				= 'D,DEFAULT (constraint or stand-alone),DEFAULT_CONSTRAINT'
						,	@Delimeter				= ','
						,	@TargetTableName		= 'ObjectType'
						,	@TargetSchemaName		= 'mssql'

	{<Usage}

	{Result}		SELECT * FROM mssql.ObjectType
									

{{<META}}
*/

ALTER     PROCEDURE [inout].[ImportFlatFileRow] 
	@RowValue				NVARCHAR(MAX)
,	@Delimeter				NVARCHAR(5) = ','
,	@TargetTableName		SYSNAME
,	@TargetSchemaName		SYSNAME

AS
BEGIN
	DECLARE @column			NVARCHAR(MAX) = ''
	DECLARE @columnCount	INT

	SELECT @column += 
	QUOTENAME(col.name) + ','
	FROM sys.columns AS col 
	INNER JOIN sys.objects AS obj
	ON obj.object_id = col.object_id
	WHERE SCHEMA_NAME(obj.schema_id) = @TargetSchemaName 
	AND obj.name = @TargetTablename
	AND col.is_identity = 0
	AND col.is_computed = 0
	AND col.default_object_id = 0
	ORDER BY col.column_id

	SET @column = SUBSTRING(@column, 1, lEN(@column) - 1)

	-- COLUMN COUNT
	SELECT @columnCount = 
	COUNT(1) 
	FROM sys.columns AS col 
	INNER JOIN sys.objects AS obj
	ON obj.object_id = col.object_id
	WHERE SCHEMA_NAME(obj.schema_id) = @TargetSchemaName 
	AND obj.name = @TargetTablename
	AND col.is_identity = 0
	AND col.is_computed = 0
	AND col.default_object_id = 0

	DECLARE @sql_statement NVARCHAR(MAX)

	-- GENERATE INSERT STATEMENT
	SET @sql_statement  = 'INSERT INTO ' + QUOTENAME(@TargetSchemaName) + '.' + QUOTENAME(@TargetTablename) 
	SET @sql_statement += '(' + @column + ')' + CHAR(13) + CHAR(10)
	SET @sql_statement += 'SELECT ' + CHAR(13) + CHAR(10) + CHAR(9)

	;WITH cte_column (
		n
	) AS (
		SELECT 
			n
		FROM
			dbo.Number
		WHERE
			n BETWEEN 1 AND @columnCount
	)
	SELECT
		@sql_statement += N'PARSENAME(REPLACE(''' + @RowValue + ''',''' + @Delimeter + ''', ''.''),' + CONVERT(VARCHAR(3), cte.n) + '),' + CHAR(13) + CHAR(10) + CHAR(9)
	FROM 
		cte_column AS cte
	ORDER BY n DESC


	SET @sql_statement = SUBSTRING(@sql_statement, 1, lEN(@sql_statement) - 4)

	EXEC sp_executesql
			@stmt = @sql_statement

END
GO
