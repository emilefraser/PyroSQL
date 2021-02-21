SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Statistic]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [meta].[Metadata_Statistic]
AS
     SELECT 
		ObjectID = obj.[object_id]
	,   SchemaName = sch.name
	,	ObjectName = obj.name
    ,   StatisticName = sta.[name]
    ,   StatisticID = sta.[stats_id]
    ,   IsAutoCreated = sta.[auto_created]
    ,   IsUserRecrated = sta.[user_created]
	,	IsTemporary = sta.[is_temporary]
	,	IsIncremental = sta.[is_incremental]
     FROM 
		sys.objects AS obj
	INNER JOIN 
		sys.stats AS sta
		ON sta.object_id = obj.object_id
	INNER JOIN 
		sys.schemas AS sch
		ON sch.schema_id = obj.object_id
' 
GO
