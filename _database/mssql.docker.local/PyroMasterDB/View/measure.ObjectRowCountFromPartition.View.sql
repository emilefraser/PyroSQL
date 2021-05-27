SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[measure].[ObjectRowCountFromPartition]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [measure].[ObjectRowCountFromPartition]
AS
	SELECT
		[DatabaseName]		= DB_NAME()
	,	[SchemaName]		= sch.[name]
	,	[ObjectName]		= tbl.[name]
	,	[RowCount]			= SUM(par.[rows]) 
	FROM
		sys.tables AS tbl
	INNER JOIN
		sys.schemas AS sch
		ON sch.schema_id = tbl.schema_id
	INNER JOIN
		sys.partitions AS par
		ON tbl.object_id = par.object_id
	INNER JOIN
		sys.indexes AS idx
		ON par.object_id = idx.object_id 
		AND par.index_id = idx.index_id
	WHERE 
		idx.index_id < 2 
	GROUP BY
		tbl.name
	,	sch.name' 
GO
