SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- select * from [STORE].[vw_StorageStats_Index]

CREATE   VIEW  [STORE].[vw_StorageStats_Index]
AS
SELECT 
	  ss_idx.[BatchID] AS [Batch ID]
      ,[Index ID] = ss_idx.[index_id]
	  ,[Index Name] = idx.[name]
      ,[Index Type] = ss_idx.[index_type]
      ,[Index Description] = ss_idx.[type_desc]
      ,ss_idx.[fill_factor] AS [Fill Factor]
      ,ss_idx.[is_unique] AS [Is Unique]
      ,ss_idx.[is_padded] AS [Is Padded]
      ,ss_idx.[size_index_total] / 1024  AS [Size Index Total (MB)] 
      ,ss_idx.[size_index_used]  / 1024 AS [Size Index Used (MB)]
      ,ss_idx.[size_index_unused]  / 1024  AS [Size Index Unused (MB)]
      ,[Table ID] = ss_idx.[table_id] 
	  ,t.[name] AS [Table Name]
      ,[Schema ID] = ss_idx.[schema_id]
	  ,[Schema Name] = sch.[name]
      ,[Database ID] = ss_idx.[database_id]
	  ,[Database Name] = db.[name]
  FROM 
	[STORE].[StorageStats_Batch] AS bat
  LEFT JOIN [STORE].[StorageStats_Index] AS ss_idx
  	ON ss_idx.BatchID = bat.BatchID
  LEFT JOIN sys.indexes AS idx
  ON idx.index_id = ss_idx.index_id
  LEFT JOIN sys.databases AS db
  ON db.database_id = ss_idx.database_id
  LEFT JOIN sys.schemas AS sch
  ON sch.schema_id = ss_idx.schema_id
  LEFT JOIN sys.tables AS t
  ON t.object_id = ss_idx.table_id
    

GO
