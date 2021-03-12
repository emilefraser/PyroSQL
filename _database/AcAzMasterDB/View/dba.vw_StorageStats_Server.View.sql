SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dba].[vw_StorageStats_Server]'))
EXEC dbo.sp_executesql @statement = N'
CREATE    VIEW [dba].[vw_StorageStats_Server]
AS
SELECT 
	bat.BatchID AS [Batch ID]
,	CONVERT(CHAR(1), REPLACE(ser.drive_mountpoint, '':\'','''')) AS [Drive MountPoint]
,	ser.drive_name AS [Drive Name]
,	ser.drive_type AS [Drive Type]
,	CONVERT(NVARCHAR(128),SERVERPROPERTY(''MachineName'')) AS [ServerName]
,	ser.size_drive_total / 1024 / 1024 AS [Drive Size Total (MB)]
,	ser.size_drive_used  / 1024 / 1024 AS [Drive Size Used (MB)]
,	ser.size_drive_unused / 1024 / 1024 AS [Drive Size Unused (MB)]
,	IIF(batcurr.CurrentBatchID IS NULL, ''No'', ''Yes'') AS [Is Current Batch]
FROM 
	[dba].[StorageStats_Batch] AS bat
LEFT JOIN 
	[dba].[StorageStats_Server] AS ser
	ON ser.BatchID = bat.BatchID
LEFT JOIN (
	SELECT MAX(BatchID) AS CurrentBatchID
	FROM [dba].[StorageStats_Batch] AS batcurr
) AS batcurr
ON batcurr.CurrentBatchID = bat.BatchID

' 
GO
