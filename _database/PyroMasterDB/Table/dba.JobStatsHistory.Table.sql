SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[JobStatsHistory]') AND type in (N'U'))
BEGIN
CREATE TABLE [dba].[JobStatsHistory](
	[JobStatsHistoryId] [int] IDENTITY(1,1) NOT NULL,
	[JobStatsID] [int] NULL,
	[JobStatsDateStamp] [datetime] NOT NULL,
	[JobName] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Category] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Enabled] [int] NULL,
	[StartTime] [datetime] NULL,
	[StopTime] [datetime] NULL,
	[AvgRunTime] [numeric](12, 2) NULL,
	[LastRunTime] [numeric](12, 2) NULL,
	[RunTimeStatus] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LastRunOutcome] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [pk_JobStatsHistory] PRIMARY KEY CLUSTERED 
(
	[JobStatsHistoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dba].[JobStatsHistory]') AND name = N'IDX_JobStatHistory_JobStatsID_INC')
CREATE NONCLUSTERED INDEX [IDX_JobStatHistory_JobStatsID_INC] ON [dba].[JobStatsHistory]
(
	[JobStatsID] ASC
)
INCLUDE([JobStatsHistoryId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dba].[JobStatsHistory]') AND name = N'IDX_JobStatHistory_JobStatsID_Status_RunTime')
CREATE NONCLUSTERED INDEX [IDX_JobStatHistory_JobStatsID_Status_RunTime] ON [dba].[JobStatsHistory]
(
	[JobStatsID] ASC,
	[RunTimeStatus] ASC,
	[LastRunTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dba].[JobStatsHistory]') AND name = N'IDX_JobStatHistory_JobStatsID_Status_RunTime_INC')
CREATE NONCLUSTERED INDEX [IDX_JobStatHistory_JobStatsID_Status_RunTime_INC] ON [dba].[JobStatsHistory]
(
	[JobStatsID] ASC,
	[RunTimeStatus] ASC,
	[LastRunTime] ASC
)
INCLUDE([StopTime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[DF_JobStatsHistory_JobStatsDateStamp]') AND type = 'D')
BEGIN
ALTER TABLE [dba].[JobStatsHistory] ADD  CONSTRAINT [DF_JobStatsHistory_JobStatsDateStamp]  DEFAULT (getdate()) FOR [JobStatsDateStamp]
END
GO
