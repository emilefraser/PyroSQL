SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE     VIEW  [STORE].[vw_StorageStats_Object]
AS
SELECT 
	  ss.[BatchID] AS [Batch ID]
      ,	db.database_id AS [Database ID]
	  ,	[Database Name] = db.name
	  ,	[Object ID] = ss.[object_id]
	  ,	[Object Name] = obj.[name]
      ,	1.00 * [size_table_total] / 1024 AS [Object Size Total (MB)] 
      ,	1.00 * 	[size_table_used] / 1024 AS [Object Size Used (MB)] 
      ,	1.00 * 	[size_table_unused] / 1024 AS [Object Size Unused (MB)] 
  FROM 
	[STORE].[StorageStats_Batch] AS bat
LEFT JOIN 
[STORE].[StorageStats_Object] AS ss
ON ss.BatchID = bat.BatchID  
LEFT JOIN sys.tables AS tab
ON tab.object_id = ss.object_id


LEFT JOIN sys.objects AS obj
  ON obj.object_id = ss.object_id

  LEFT JOIN sys.databases AS db
  ON db.database_id = ss.database_id
  LEFT JOIN sys.schemas AS sch
  ON sch.schema_id = ss.schema_id
  LEFT JOIN (
	SELECT MAX(BatchID) AS CurrentBatchID
	FROM [STORE].[StorageStats_Batch] AS batcurr
) AS batcurr
ON batcurr.CurrentBatchID = bat.BatchID
  WHERE
	ss.object_type = 'U'
	AND tab.object_id is not null

    

GO
