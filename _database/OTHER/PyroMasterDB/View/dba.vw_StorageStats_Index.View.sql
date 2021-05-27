SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dba].[vw_StorageStats_Index]'))
EXEC dbo.sp_executesql @statement = N'
CREATE   VIEW  [dba].[vw_StorageStats_Index]
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
	[dba].[StorageStats_Batch] AS bat
  LEFT JOIN [dba].[StorageStats_Index] AS ss_idx
  	ON ss_idx.BatchID = bat.BatchID
  LEFT JOIN sys.indexes AS idx
  ON idx.index_id = ss_idx.index_id
  LEFT JOIN sys.databases AS db
  ON db.database_id = ss_idx.database_id
  LEFT JOIN sys.schemas AS sch
  ON sch.schema_id = ss_idx.schema_id
  LEFT JOIN sys.tables AS t
  ON t.object_id = ss_idx.table_id
' 
GO
