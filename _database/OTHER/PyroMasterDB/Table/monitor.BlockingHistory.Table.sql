SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[monitor].[BlockingHistory]') AND type in (N'U'))
BEGIN
CREATE TABLE [monitor].[BlockingHistory](
	[BlockingHistoryID] [int] IDENTITY(1,1) NOT NULL,
	[DateStamp] [datetime] NOT NULL,
	[Blocked_SPID] [smallint] NOT NULL,
	[Blocking_SPID] [smallint] NOT NULL,
	[Blocked_Login] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Blocked_HostName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Blocked_WaitTime_Seconds] [numeric](12, 2) NULL,
	[Blocked_LastWaitType] [nvarchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Blocked_Status] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Blocked_Program] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Blocked_SQL_Text] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Offending_SPID] [smallint] NOT NULL,
	[Offending_Login] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Offending_NTUser] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Offending_HostName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Offending_WaitType] [bigint] NOT NULL,
	[Offending_LastWaitType] [nvarchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Offending_Status] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Offending_Program] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Offending_SQL_Text] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DBName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [pk_BlockingHistory] PRIMARY KEY CLUSTERED 
(
	[BlockingHistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[monitor].[DF_BlockingHistory_DateStamp]') AND type = 'D')
BEGIN
ALTER TABLE [monitor].[BlockingHistory] ADD  CONSTRAINT [DF_BlockingHistory_DateStamp]  DEFAULT (getdate()) FOR [DateStamp]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[monitor].[ti_blockinghistory]'))
EXEC dbo.sp_executesql @statement = N'CREATE TRIGGER [monitor].[ti_blockinghistory] ON [monitor].[BlockingHistory] INSTEAD OF INSERT AS SELECT 1' 
GO
ALTER TABLE [monitor].[BlockingHistory] ENABLE TRIGGER [ti_blockinghistory]
GO
