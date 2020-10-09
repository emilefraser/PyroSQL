SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [SCHEDULER].[SchedulerHeader_BackupFG](
	[SchedulerHeaderID] [int] IDENTITY(1,1) NOT NULL,
	[ETLLoadConfigID] [int] NULL,
	[ScheduleExecutionIntervalMinutes] [int] NULL,
	[ScheduleExecutionTime] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
