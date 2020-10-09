SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [STORE].[StorageStats_Batch](
	[BatchID] [int] IDENTITY(1,1) NOT NULL,
	[HasStorageStatsRun_Machine] [bit] NOT NULL,
	[HasStorageStatsRun_Database] [bit] NOT NULL,
	[HasStorageStatsRun_DatabaseFile] [bit] NOT NULL,
	[HasStorageStatsRun_Object] [bit] NOT NULL,
	[HasStorageStatsRun_Index] [bit] NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NOT NULL
) ON [PRIMARY]

GO
