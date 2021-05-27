SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Statistic]'))
EXEC dbo.sp_executesql @statement = N'/*
	SELECT * FROM  [meta].[Metadata_Statistic] 
	WHERE IsNoRows = 0 
	AND (
		IsStatisticOlderThan1Day = 1 
		OR IsStatisticRowModCtrGreater10 = 1
	)
*/
CREATE   VIEW [meta].[Metadata_Statistic]
AS
     SELECT ''dummy'' AS dummy
	-- 	StatisticId							= stat.[stats_id]
 --   ,   StatisticName						= sidx.[name]
	--,	ObjectID							= obj.[object_id]
	--,   SchemaName							= sch.[name]
	--,	ObjectName							= obj.[name]
 --   ,   IsAutoCreated						= stat.[auto_created]
 --   ,   IsUserRecrated						= stat.[user_created]
	--,	IsTemporary							= stat.[is_temporary]
	--,	IsIncremental						= stat.[is_incremental]
	--,	StatisticCreationMethod				= stat.[stats_generation_method]
	--,	StatisticCreationDescription		= stat.[stats_generation_method_desc]
	--,	RowsActual							= statprop.[rows]
	--,	RowsCount							= sidx.rowcnt
	--,	RowModCtr							= sidx.[rowmodctr]
	--,	RowsSampled							= statprop.[rows_sampled]
	--,	RowsUnfiltered						= statprop.[unfiltered_rows]
	--,	StatsLastUpdateDate					= STATS_DATE(sidx.id, sidx.indid)
	--,	IsNoRows							= IIF(sidx.rowcnt = 0, 1, 0)
	--,	IsStatisticOlderThan1Day			= IIF(STATS_DATE(sidx.id, sidx.indid) <= DATEADD(DAY, -1, GETDATE()), 1, 0)
	--,	IsStatisticRowModCtrGreater10		= IIF(sidx.rowmodctr > 10, 1, 0)
	--FROM
	--	sys.sysindexes  as sidx
	--INNER JOIN 
	--	sys.tables AS tab
	--	ON tab.object_id = sidx.id
	--INNER JOIN 
	--	sys.objects AS obj
	--	ON obj.object_id = tab.object_id
	--INNER JOIN 
	--	sys.schemas AS sch
	--	ON sch.schema_id = tab.schema_id
	--INNER JOIN 
	--	sys.stats AS stat
	--	ON stat.object_id = sidx.id
	--	AND stat.stats_id = sidx.indid
	--CROSS APPLY 
	--	sys.meta_db_stats_properties(stat.object_id, stat.stats_id) AS statprop


' 
GO
