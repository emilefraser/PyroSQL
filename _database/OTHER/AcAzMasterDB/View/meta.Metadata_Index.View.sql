SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Index]'))
EXEC dbo.sp_executesql @statement = N'


/*
	SELECT * FROM [meta].[Metadata_Index]
*/
CREATE    VIEW [meta].[Metadata_Index]
AS
WITH cte_space (
	ObjectId
,	IndexId
,	AllocatedSpace
,	UsedSpace
) AS (
	select 
		ObjectId		= obj.object_id
	  , IndexId			= idx.index_id
      ,	AllocatedSpace	= (SUM(aut.total_pages * 8) / 1024.0)
      , UsedSpace		= (SUM(aut.used_pages * 8) / 1024.0)
	FROM
		sys.objects AS obj
	INNER JOIN
		sys.indexes AS idx
		ON obj.object_id = idx.object_id
	LEFT JOIN 
		sys.partitions AS par
		ON par.object_id = idx.object_id
		AND par.index_id = idx.index_id
	LEFT JOIN 
		sys.allocation_units AS aut
		ON aut.container_id = par.partition_id
	WHERE
		obj.is_ms_shipped <> 1
		AND idx.index_id > 0
	GROUP BY 
		obj.object_id
	,	idx.index_id
)
SELECT
	IndexName =	   idx.[name]
  , IndexType =	   
			   CASE
				   WHEN idx.[type] = 1
					   THEN ''Clustered index''
				   WHEN idx.[type] = 2
					   THEN ''Nonclustered unique index''
				   WHEN idx.[type] = 3
					   THEN ''XML index''
				   WHEN idx.[type] = 4
					   THEN ''Spatial index''
				   WHEN idx.[type] = 5
					   THEN ''Clustered columnstore index''
				   WHEN idx.[type] = 6
					   THEN ''Nonclustered columnstore index''
				   WHEN idx.[type] = 7
					   THEN ''Nonclustered hash index''
			   END
  , IsUniqueIndex =
				   CASE
					   WHEN idx.is_unique = 1
						   THEN ''Unique''
					   ELSE ''Not unique''
				   END
  , SchemaName =   SCHEMA_NAME(obj.schema_id)
  , ObjectName =   obj.name
  , ObjectType =   obj.type
  , ObjectTypeDescription =   
							CASE
								WHEN obj.type = ''U''
									THEN ''Table''
								WHEN obj.type = ''V''
									THEN ''View''
							END
  , AllocatedSpace = cte.AllocatedSpace
  , UsedSpace      = cte.UsedSpace
  , ColumnName	   = SUBSTRING(column_names, 1, LEN(column_names) - 1)
  ,	UserSeek	   = idxus.user_seeks
  , UserScan	   = idxus.user_seeks
  , UserLookup	   = idxus.user_seeks
  , UserUpdate	   = idxus.user_seeks
FROM
	sys.objects AS obj
INNER JOIN
	sys.indexes AS idx
	ON obj.object_id = idx.object_id
CROSS APPLY
	(
		SELECT
			col.[name] + '', ''
		FROM
			sys.index_columns AS idxc
		INNER JOIN
			sys.columns AS col
			ON idxc.object_id = col.object_id
			AND idxc.column_id = col.column_id
		WHERE
			idxc.object_id = obj.object_id
			AND idxc.index_id = idx.index_id
		ORDER BY
			key_ordinal
		FOR XML
			PATH ('''')
	) d (column_names)
LEFT JOIN 
	cte_space AS cte
	ON cte.ObjectId = obj.object_id
	AND	cte.IndexId = idx.index_id
LEFT JOIN 
	sys.dm_db_index_usage_stats as idxus
	ON idxus.object_id = obj.object_id
	AND	idxus.object_id = idx.object_id
WHERE
	obj.is_ms_shipped <> 1
	AND idx.index_id > 0


' 
GO
