SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PerfStatsHistory](
	[PerfStatsHistoryID] [int] IDENTITY(1,1) NOT NULL,
	[BufferCacheHitRatio] [numeric](38, 13) NULL,
	[PageLifeExpectency] [bigint] NULL,
	[BatchRequestsPerSecond] [bigint] NULL,
	[CompilationsPerSecond] [bigint] NULL,
	[ReCompilationsPerSecond] [bigint] NULL,
	[UserConnections] [bigint] NULL,
	[LockWaitsPerSecond] [bigint] NULL,
	[PageSplitsPerSecond] [bigint] NULL,
	[ProcessesBlocked] [bigint] NULL,
	[CheckpointPagesPerSecond] [bigint] NULL,
	[StatDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
