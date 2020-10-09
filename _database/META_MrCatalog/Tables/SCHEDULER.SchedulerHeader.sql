SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [SCHEDULER].[SchedulerHeader](
	[SchedulerHeaderID] [int] IDENTITY(1,1) NOT NULL,
	[ETLLoadConfigID] [int] NULL,
	[ScheduleExecutionIntervalMinutes] [int] NULL,
	[ScheduleExecutionTime] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsActive] [bit] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL
) ON [PRIMARY]

GO
