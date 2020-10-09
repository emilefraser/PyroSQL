SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysmaintplan_log](
	[task_detail_id] [uniqueidentifier] NOT NULL,
	[plan_id] [uniqueidentifier] NULL,
	[subplan_id] [uniqueidentifier] NULL,
	[start_time] [datetime] NULL,
	[end_time] [datetime] NULL,
	[succeeded] [bit] NULL,
	[logged_remotely] [bit] NOT NULL,
	[source_server_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[plan_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[subplan_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
