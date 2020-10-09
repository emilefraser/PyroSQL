SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BlockingHistory](
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
	[DBName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
