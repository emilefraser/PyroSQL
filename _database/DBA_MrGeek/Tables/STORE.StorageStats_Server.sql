SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [STORE].[StorageStats_Server](
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

GO
