SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



CREATE VIEW [STORE].[vw_StorageStats_ServerDiskSpace]
AS
SELECT DISTINCT
	Drive = B.volume_mount_point,
	Name = B.logical_volume_name,
	DiskSpaceUsed = CONVERT(int, 100 * (1 - (CONVERT(decimal,B.available_bytes/1048576.0) / CONVERT(decimal,B.total_bytes/1048576.0)))),
	FreeDiskSpaceInMB = CONVERT(int,B.available_bytes/1048576.0),
	TotalDiskSpaceInMB = CONVERT(int,B.total_bytes/1048576.0)
FROM sys.master_files A
CROSS APPLY sys.dm_os_volume_stats(A.database_id, A.FILE_ID) B

GO
