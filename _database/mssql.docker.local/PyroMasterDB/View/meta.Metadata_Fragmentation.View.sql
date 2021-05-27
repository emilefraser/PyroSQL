SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Fragmentation]'))
EXEC dbo.sp_executesql @statement = N'

/*
	SELECT * FROM [meta].[Metadata_Fragmentation]
*/
CREATE   VIEW [meta].[Metadata_Fragmentation]
AS

SELECT ''Fragmentation'' AS dummy
--	IndexName =	   idx.[name]
--  , IndexType =	   
--			   CASE
--				   WHEN idx.[type] = 1
--					   THEN ''Clustered index''
--				   WHEN idx.[type] = 2
--					   THEN ''Nonclustered unique index''
--				   WHEN idx.[type] = 3
--					   THEN ''XML index''
--				   WHEN idx.[type] = 4
--					   THEN ''Spatial index''
--				   WHEN idx.[type] = 5
--					   THEN ''Clustered columnstore index''
--				   WHEN idx.[type] = 6
--					   THEN ''Nonclustered columnstore index''
--				   WHEN idx.[type] = 7
--					   THEN ''Nonclustered hash index''
--			   END
--  , IsUniqueIndex =
--				   CASE
--					   WHEN idx.is_unique = 1
--						   THEN ''Unique''
--					   ELSE ''Not unique''
--				   END
--  , SchemaName =   sch.name
--  , ObjectName =   obj.name
--  , ObjectType =   obj.type
--  ,	AverageFragmentationPercent = idxpstat.avg_fragmentation_in_percent
--  , PageCount = idxpstat.page_count
--  ,	RecordCount = idxpstat.record_count
--  , FragmentCount = idxpstat.fragment_count
--FROM
--	sys.objects AS obj
--INNER JOIN 
--	sys.tables AS tab
--	ON tab.object_id = obj.object_id
--INNER JOIN
--	sys.indexes AS idx
--	ON obj.object_id = idx.object_id
--INNER JOIN 
--	sys.schemas AS sch
--	ON sch.schema_id = obj.schema_id
--INNER JOIN 
--	sys.meta_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, ''SAMPLED'') AS idxpstat
--	ON tab.object_id = idxpstat.object_id
--WHERE
--	obj.is_ms_shipped <> 1
--	AND idx.index_id > 0


' 
GO
