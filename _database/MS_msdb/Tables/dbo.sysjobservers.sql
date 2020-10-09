SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysjobservers](
	[job_id] [uniqueidentifier] NOT NULL,
	[server_id] [int] NOT NULL,
	[last_run_outcome] [tinyint] NOT NULL,
	[last_outcome_message] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[last_run_date] [int] NOT NULL,
	[last_run_time] [int] NOT NULL,
	[last_run_duration] [int] NOT NULL
) ON [PRIMARY]

GO
