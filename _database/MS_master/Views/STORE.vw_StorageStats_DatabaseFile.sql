SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE    VIEW [STORE].[vw_StorageStats_DatabaseFile]
AS
SELECT 
	bat.BatchID AS [Batch ID]
,	dbf.[file_id] AS [File ID]
,	dbf.[file_name] AS [File Name]
,	dbf.[file_type_desc] AS [File Type Description]
,	dbf.[file_classification] AS [File Classification]
,	dbf.[file_path] AS [File Path]
,	REPLACE(dbf.[file_drive], ':', '') AS [File Drive]
,	dbf.[size_file] / 1024  AS [File Size (MB)]
,	dbf.[max_size] AS [Max Size]
,	dbf.[growth] AS [Growth (MB)]
,	dbf.[database_id] AS [Database ID]
,	[SqlServerInstanceName] AS [Database Instance Name]
,	[MachineName] AS [Server Name]
FROM 
	[STORE].[StorageStats_Batch] AS bat
LEFT JOIN 
	[STORE].[StorageStats_DatabaseFile] AS dbf
	ON dbf.BatchID = bat.BatchID
LEFT JOIN (
	SELECT MAX(BatchID) AS CurrentBatchID
	FROM [STORE].[StorageStats_Batch] AS batcurr
) AS batcurr
ON batcurr.CurrentBatchID = bat.BatchID

GO
