SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dba].[vw_StorageStats_Database]'))
EXEC dbo.sp_executesql @statement = N'
CREATE    VIEW [dba].[vw_StorageStats_Database]
AS
SELECT 
	bat.BatchID AS [Batch ID]
,	db.[database_id] AS [Database ID]
,	d.[name] AS [Database Name]
,	db.[size_database] * 8 / 1024 AS [Database Size (MB)]
,	db.[state_desc] AS [State]
,	db.[recovery_model_desc] AS [Recovery Model]
,	IIF(db.[is_auto_create_stats_on] = 1 , ''Yes'', ''No'') AS [Is Auto Create Stats On]
,	IIF(db.[is_auto_update_stats_on]= 1 , ''Yes'', ''No'') AS [Is Auto Update Stats On]
,	IIF(db.[is_auto_shrink_on]= 1 , ''Yes'', ''No'') AS [Is Auto Shrink On]
,	IIF(db.[is_ansi_padding_on]= 1 , ''Yes'', ''No'') AS [Is ANSI Padding On]
,	IIF(db.[is_fulltext_enabled]= 1 , ''Yes'', ''No'') AS [Is Fulltext On]
,	IIF(db.[is_query_store_on]= 1 , ''Yes'', ''No'') AS [Is Query Store On]
,	IIF(db.[is_temporal_history_retention_enabled]= 1 , ''Yes'', ''No'') AS [Is Temporal History ON]
FROM 
	[dba].[StorageStats_Batch] AS bat
LEFT JOIN 
	[dba].[StorageStats_Database] AS db
	ON db.BatchID = bat.BatchID
INNER JOIN 
	sys.databases AS d
	ON d.database_id = db.database_id
LEFT JOIN (
	SELECT MAX(BatchID) AS CurrentBatchID
	FROM [dba].[StorageStats_Batch] AS batcurr
) AS batcurr
ON batcurr.CurrentBatchID = bat.BatchID

' 
GO
