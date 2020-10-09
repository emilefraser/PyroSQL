SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE   FUNCTION dbo.GetSchemaRowCountFromPartitions (@SchemaName SYSNAME, @StageOfLoad NVARCHAR(128))
RETURNS TABLE
AS
RETURN
	SELECT
			[StageOfLoad]	= @StageOfLoad
		  , [EntityName]	= tbl.[name]
		  , [DatabaseName]	= DB_NAME()
		  , [SchemaName]	= sch.[name]
		  , [TableName]		= tbl.[name]
		  , [RowCount]		= SUM(par.[rows]) 
		FROM
			[sys].[tables] AS tbl
		INNER JOIN
			[sys].[schemas] AS sch
			ON sch.schema_id = tbl.schema_id
		INNER JOIN
			[sys].[partitions] AS par
			ON tbl.object_id = par.object_id
		INNER JOIN
			[sys].[indexes] AS idx
			ON par.object_id = idx.object_id 
			AND par.[index_id] = idx.[index_id]
		WHERE 
			idx.[index_id] < 2 
		AND 
			sch.[name] = @SchemaName
		GROUP BY
			tbl.object_id
		  , tbl.[name]
		  , sch.[name]
GO
