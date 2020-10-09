SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE    VIEW [STORE].[vw_StorageStats_Server]
AS
SELECT 
	bat.BatchID AS [Batch ID]
,	CONVERT(CHAR(1), REPLACE(ser.drive_mountpoint, ':\','')) AS [Drive MountPoint]
,	ser.drive_name AS [Drive Name]
,	ser.drive_type AS [Drive Type]
,	CONVERT(NVARCHAR(128),SERVERPROPERTY('MachineName')) AS [ServerName]
,	ser.size_drive_total / 1024 / 1024 AS [Drive Size Total (MB)]
,	ser.size_drive_used  / 1024 / 1024 AS [Drive Size Used (MB)]
,	ser.size_drive_unused / 1024 / 1024 AS [Drive Size Unused (MB)]
,	IIF(batcurr.CurrentBatchID IS NULL, 'No', 'Yes') AS [Is Current Batch]
FROM 
	[STORE].[StorageStats_Batch] AS bat
LEFT JOIN 
	[STORE].[StorageStats_Server] AS ser
	ON ser.BatchID = bat.BatchID
LEFT JOIN (
	SELECT MAX(BatchID) AS CurrentBatchID
	FROM [STORE].[StorageStats_Batch] AS batcurr
) AS batcurr
ON batcurr.CurrentBatchID = bat.BatchID

GO
