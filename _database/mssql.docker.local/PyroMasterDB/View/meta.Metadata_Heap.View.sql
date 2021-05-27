SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Heap]'))
EXEC dbo.sp_executesql @statement = N'

/*
	SELECT * FROM [meta].[Metadata_Heap]
*/
CREATE   VIEW [meta].[Metadata_Heap]
AS

SELECT
    IndexType =	   ''Heap''
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
--	AND idx.index_id = 0


' 
GO
