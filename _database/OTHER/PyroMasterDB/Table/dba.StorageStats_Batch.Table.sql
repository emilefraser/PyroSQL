SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[StorageStats_Batch]') AND type in (N'U'))
BEGIN
CREATE TABLE [dba].[StorageStats_Batch](
	[BatchID] [int] IDENTITY(1,1) NOT NULL,
	[HasStorageStatsRun_Machine] [bit] NOT NULL,
	[HasStorageStatsRun_Database] [bit] NOT NULL,
	[HasStorageStatsRun_DatabaseFile] [bit] NOT NULL,
	[HasStorageStatsRun_Object] [bit] NOT NULL,
	[HasStorageStatsRun_Index] [bit] NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NOT NULL
) ON [PRIMARY]
END
GO
