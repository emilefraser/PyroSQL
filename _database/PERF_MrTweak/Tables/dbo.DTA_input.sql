SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DTA_input](
	[SessionName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SessionID] [int] IDENTITY(1,1) NOT NULL,
	[TuningOptions] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreationTime] [datetime] NOT NULL,
	[ScheduledStartTime] [datetime] NOT NULL,
	[ScheduledJobName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[InteractiveStatus] [tinyint] NOT NULL,
	[LogTableName] [nvarchar](1280) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[GlobalSessionID] [uniqueidentifier] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
