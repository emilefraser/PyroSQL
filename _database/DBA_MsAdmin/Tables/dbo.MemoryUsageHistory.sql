SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MemoryUsageHistory](
	[MemoryUsageHistoryID] [int] IDENTITY(1,1) NOT NULL,
	[DateStamp] [datetime] NOT NULL,
	[SystemPhysicalMemoryMB] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SystemVirtualMemoryMB] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DBUsageMB] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DBMemoryRequiredMB] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BufferCacheHitRatio] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BufferPageLifeExpectancy] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BufferPoolCommitMB] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BufferPoolCommitTgtMB] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BufferPoolTotalPagesMB] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BufferPoolDataPagesMB] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BufferPoolFreePagesMB] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BufferPoolReservedPagesMB] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BufferPoolStolenPagesMB] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BufferPoolPlanCachePagesMB] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DynamicMemConnectionsMB] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DynamicMemLocksMB] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DynamicMemSQLCacheMB] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DynamicMemQueryOptimizeMB] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DynamicMemHashSortIndexMB] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CursorUsageMB] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
