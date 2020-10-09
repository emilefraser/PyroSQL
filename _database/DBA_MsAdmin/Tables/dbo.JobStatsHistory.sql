SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[JobStatsHistory](
	[JobStatsHistoryId] [int] IDENTITY(1,1) NOT NULL,
	[JobStatsID] [int] NULL,
	[JobStatsDateStamp] [datetime] NOT NULL,
	[JobName] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Owner] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Category] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Enabled] [int] NULL,
	[StartTime] [datetime] NULL,
	[StopTime] [datetime] NULL,
	[AvgRunTime] [numeric](12, 2) NULL,
	[LastRunTime] [numeric](12, 2) NULL,
	[RunTimeStatus] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LastRunOutcome] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
