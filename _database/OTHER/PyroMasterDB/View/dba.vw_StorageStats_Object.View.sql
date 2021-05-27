SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dba].[vw_StorageStats_Object]'))
EXEC dbo.sp_executesql @statement = N'
CREATE     VIEW  [dba].[vw_StorageStats_Object]
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
	[dba].[StorageStats_Batch] AS bat
LEFT JOIN 
[dba].[StorageStats_Object] AS ss
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
	FROM [dba].[StorageStats_Batch] AS batcurr
) AS batcurr
ON batcurr.CurrentBatchID = bat.BatchID
  WHERE
	ss.object_type = ''U''
	AND tab.object_id is not null
' 
GO
