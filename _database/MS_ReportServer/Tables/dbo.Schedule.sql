SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Schedule](
	[ScheduleID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[Flags] [int] NOT NULL,
	[NextRunTime] [datetime] NULL,
	[LastRunTime] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[RecurrenceType] [int] NULL,
	[MinutesInterval] [int] NULL,
	[DaysInterval] [int] NULL,
	[WeeksInterval] [int] NULL,
	[DaysOfWeek] [int] NULL,
	[DaysOfMonth] [int] NULL,
	[Month] [int] NULL,
	[MonthlyWeek] [int] NULL,
	[State] [int] NULL,
	[LastRunStatus] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ScheduledRunTimeout] [int] NULL,
	[CreatedById] [uniqueidentifier] NOT NULL,
	[EventType] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[EventData] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Type] [int] NOT NULL,
	[ConsistancyCheck] [datetime] NULL,
	[Path] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
) ON [PRIMARY]

GO
