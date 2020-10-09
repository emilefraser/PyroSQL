SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysmaintplan_subplans](
	[subplan_id] [uniqueidentifier] NOT NULL,
	[subplan_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[subplan_description] [nvarchar](512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[plan_id] [uniqueidentifier] NOT NULL,
	[job_id] [uniqueidentifier] NOT NULL,
	[msx_job_id] [uniqueidentifier] NULL,
	[schedule_id] [int] NULL,
	[msx_plan] [bit] NOT NULL
) ON [PRIMARY]

GO
