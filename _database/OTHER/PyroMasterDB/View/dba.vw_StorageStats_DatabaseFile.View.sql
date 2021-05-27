SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dba].[vw_StorageStats_DatabaseFile]'))
EXEC dbo.sp_executesql @statement = N'
CREATE    VIEW [dba].[vw_StorageStats_DatabaseFile]
AS
SELECT 
	bat.BatchID AS [Batch ID]
,	dbf.[file_id] AS [File ID]
,	dbf.[file_name] AS [File Name]
,	dbf.[file_type_desc] AS [File Type Description]
,	dbf.[file_classification] AS [File Classification]
,	dbf.[file_path] AS [File Path]
,	REPLACE(dbf.[file_drive], '':'', '''') AS [File Drive]
,	dbf.[size_file] / 1024  AS [File Size (MB)]
,	dbf.[max_size] AS [Max Size]
,	dbf.[growth] AS [Growth (MB)]
,	dbf.[database_id] AS [Database ID]
,	[SqlServerInstanceName] AS [Database Instance Name]
,	[MachineName] AS [Server Name]
FROM 
	[dba].[StorageStats_Batch] AS bat
LEFT JOIN 
	[dba].[StorageStats_DatabaseFile] AS dbf
	ON dbf.BatchID = bat.BatchID
LEFT JOIN (
	SELECT MAX(BatchID) AS CurrentBatchID
	FROM [dba].[StorageStats_Batch] AS batcurr
) AS batcurr
ON batcurr.CurrentBatchID = bat.BatchID

' 
GO
