SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[productivity].[ExpandStarWithColumnList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [productivity].[ExpandStarWithColumnList] AS' 
END
GO
-- EXEC [productivity].[ExpandStarWithColumnList]  'asset.AssetRegister AS abc'
-- EXEC [productivity].[ExpandStarWithColumnList]  '[asset].[AssetRegister] AS abc'
ALTER     PROCEDURE [productivity].[ExpandStarWithColumnList] 
    @SchemaObjectAliasString		NVARCHAR(MAX)
AS
BEGIN
	DECLARE
		@SchemaName		SYSNAME = 'dbo'
	  , @ObjectName		SYSNAME
	  , @Alias			CHAR(20) = NULL
	  ,	@ObjectPrefix	CHAR(20) = NULL

	SET @SchemaObjectAliasString = REPLACE(REPLACE(@SchemaObjectAliasString, ']', ''), '[', '')	

	IF (CHARINDEX('.', @SchemaObjectAliasString) > 1)
	BEGIN
		SET @SchemaName = SUBSTRING(@SchemaObjectAliasString, 1, CHARINDEX('.', @SchemaObjectAliasString) - 1)
		SET @ObjectName = SUBSTRING(@SchemaObjectAliasString, 
										CHARINDEX('.', @SchemaObjectAliasString) + 1, 
										(CHARINDEX(' AS ', @SchemaObjectAliasString) - 1) - CHARINDEX('.', @SchemaObjectAliasString) + 1
									)
		SET @Alias = SUBSTRING(@SchemaObjectAliasString, CHARINDEX(' AS ', @SchemaObjectAliasString) + 3, 20)
		SET @ObjectPrefix = LTRIM(RTRIM(UPPER(REPLACE(REPLACE(@Alias, '_', ''), '-', ''))))
	END
	ELSE 
	BEGIN
		SET @SchemaName = 'dbo'
		SET @ObjectName = SUBSTRING(@SchemaObjectAliasString, 1, CHARINDEX(' AS ', @SchemaObjectAliasString) - 1)
		SET @Alias = SUBSTRING(@SchemaObjectAliasString, CHARINDEX(' AS ', @SchemaObjectAliasString) + 3, 20)
		SET @ObjectPrefix = LTRIM(RTRIM(UPPER(REPLACE(REPLACE(@Alias, '_', ''), '-', ''))))
	END

	DECLARE 
		@ColumnList    NVARCHAR(MAX) = '';

	WITH cte_parameter AS (
		SELECT
			MaxColumnId = tab.max_column_id_used
		,	SqlClrf     = CHAR(13) + CHAR(10)
		,	SqlTab		= CHAR(9)
		FROM
			sys.tables AS tab
		INNER JOIN
			sys.schemas AS sch
			ON sch.schema_id = tab.schema_id
		WHERE 
			tab.[name] = LTRIM(RTRIM(@ObjectName))
		AND
			sch.name = LTRIM(RTRIM(@SchemaName))
	), cte_columnlist AS (
		SELECT   
			ColumnName = col.name 
		,	ColumnId   = col.column_id
		FROM   
			sys.tables tab
		INNER JOIN
			sys.schemas AS sch
			ON sch.schema_id = tab.schema_id
		INNER JOIN
			sys.all_columns AS col
			ON col.object_id = tab.object_id
		WHERE 
			tab.name = LTRIM(RTRIM(@ObjectName))
		AND
			sch.name = LTRIM(RTRIM(@SchemaName))
	)
	SELECT
		@ColumnList += IIF(cl.ColumnId = 1, '', ',')
							+ cp.SqlTab 
							+ ISNULL(LTRIM(RTRIM(@Alias)) + '.', '') 
							+ QUOTENAME(CONCAT(LTRIM(RTRIM(@ObjectPrefix)), '_', LTRIM(RTRIM(cl.ColumnName))))
							+ cp.SqlClrf
	FROM
		cte_columnlist AS cl
	CROSS JOIN 
		cte_parameter AS cp


	SELECT @ColumnList

END;
GO
