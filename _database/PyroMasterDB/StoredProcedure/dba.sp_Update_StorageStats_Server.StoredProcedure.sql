SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[sp_Update_StorageStats_Server]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[sp_Update_StorageStats_Server] AS' 
END
GO

/*
	DECLARE @BatchID INT = 1
	EXEC master.dbo.sp_Update_StorageStats_Server @BatchID
*/
ALTER     PROCEDURE [dba].[sp_Update_StorageStats_Server]
			@BatchID INT
AS
BEGIN

	-- If the table for Storage tracking doesnt exists for so
	IF OBJECT_ID('dba.StorageStats_Server', 'U') IS NULL
	BEGIN 
		CREATE TABLE dba.[StorageStats_Server](
		   [StorageStats_DatabaseFile_ID] [int] IDENTITY NOT NULL
		  ,[BatchID] [int] NOT NULL
		  ,[drive_mountpoint] nvarchar(100) NULL
		  ,[drive_name]  nvarchar(100) NULL
		  ,[drive_type] nvarchar(100) NULL
		  ,[size_drive_total] bigint NULL
		  ,[size_drive_used] bigint NULL
		  ,[size_drive_unused] bigint NULL
		  ,CreatedDT DATEtime2(7) not null default getdate()
		)

	END

	INSERT INTO dba.[StorageStats_Server]
	(
       [BatchID]
      ,[drive_mountpoint]
      ,[drive_name]
      ,[drive_type]
      ,[size_drive_total]
      ,[size_drive_used]
	  ,[size_drive_unused]
	)
	SELECT DISTINCT 
		@BatchID
	,	dovs.volume_mount_point AS drive_mountpoint
	,	dovs.logical_volume_name AS [drive_name]
	,	dovs.file_system_type AS [drive_type]
	,	dovs.total_bytes AS [size_drive_total]
	,	dovs.total_bytes - dovs.available_bytes AS [size_drive_used]
	,	dovs.available_bytes AS [size_drive_unused]
FROM 
	sys.master_files mf
CROSS APPLY 
	sys.dm_os_volume_stats(mf.database_id, mf.FILE_ID) dovs


END
GO
