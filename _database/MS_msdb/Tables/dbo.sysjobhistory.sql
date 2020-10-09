SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysjobhistory](
	[instance_id] [int] IDENTITY(1,1) NOT NULL,
	[job_id] [uniqueidentifier] NOT NULL,
	[step_id] [int] NOT NULL,
	[step_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[sql_message_id] [int] NOT NULL,
	[sql_severity] [int] NOT NULL,
	[message] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[run_status] [int] NOT NULL,
	[run_date] [int] NOT NULL,
	[run_time] [int] NOT NULL,
	[run_duration] [int] NOT NULL,
	[operator_id_emailed] [int] NOT NULL,
	[operator_id_netsent] [int] NOT NULL,
	[operator_id_paged] [int] NOT NULL,
	[retries_attempted] [int] NOT NULL,
	[server] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
