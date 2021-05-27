SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[PerfStatsHistory]') AND type in (N'U'))
BEGIN
CREATE TABLE [dba].[PerfStatsHistory](
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
	[StatDate] [datetime] NOT NULL,
 CONSTRAINT [PK_PerfStatsHistory] PRIMARY KEY CLUSTERED 
(
	[PerfStatsHistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
