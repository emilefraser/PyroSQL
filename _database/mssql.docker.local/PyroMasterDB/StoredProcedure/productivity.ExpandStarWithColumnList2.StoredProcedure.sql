SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[productivity].[ExpandStarWithColumnList2]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [productivity].[ExpandStarWithColumnList2] AS' 
END
GO
ALTER     PROCEDURE [productivity].[ExpandStarWithColumnList2] 
    @SchemaName		SYSNAME = 'dbo'
  , @ObjectName		SYSNAME
  , @Alias			CHAR(20) = NULL
AS
BEGIN
	--DECLARE 
	--@SchemaName		SYSNAME = 'asset'
 -- , @ObjectName		SYSNAME = 'AssetRegister'
 -- , @Alias			CHAR(20) = 'areg' --NULL

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
							+ QUOTENAME(cl.ColumnName) 
							+ cp.SqlClrf
	FROM
		cte_columnlist AS cl
	CROSS JOIN 
		cte_parameter AS cp


	SELECT @ColumnList

END;
GO
