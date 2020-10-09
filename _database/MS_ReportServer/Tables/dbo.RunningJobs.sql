SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[RunningJobs](
	[JobID] [nvarchar](32) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[ComputerName] [nvarchar](32) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[RequestName] [nvarchar](425) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[RequestPath] [nvarchar](425) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[Description] [ntext] COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Timeout] [int] NOT NULL,
	[JobAction] [smallint] NOT NULL,
	[JobType] [smallint] NOT NULL,
	[JobStatus] [smallint] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
