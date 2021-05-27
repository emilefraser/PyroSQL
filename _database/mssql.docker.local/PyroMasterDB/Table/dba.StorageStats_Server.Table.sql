SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[StorageStats_Server]') AND type in (N'U'))
BEGIN
CREATE TABLE [dba].[StorageStats_Server](
	[StorageStats_DatabaseFile_ID] [int] IDENTITY(1,1) NOT NULL,
	[BatchID] [int] NOT NULL,
	[drive_mountpoint] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[drive_name] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[drive_type] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[size_drive_total] [bigint] NULL,
	[size_drive_used] [bigint] NULL,
	[size_drive_unused] [bigint] NULL,
	[CreatedDT] [datetime2](7) NOT NULL
) ON [PRIMARY]
END
GO
