SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysjobschedules](
	[schedule_id] [int] NULL,
	[job_id] [uniqueidentifier] NULL,
	[next_run_date] [int] NOT NULL,
	[next_run_time] [int] NOT NULL
) ON [PRIMARY]

GO
