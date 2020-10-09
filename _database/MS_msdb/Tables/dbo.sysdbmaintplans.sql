SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysdbmaintplans](
	[plan_id] [uniqueidentifier] NOT NULL,
	[plan_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[date_created] [datetime] NOT NULL,
	[owner] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[max_history_rows] [int] NOT NULL,
	[remote_history_server] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[max_remote_history_rows] [int] NOT NULL,
	[user_defined_1] [int] NULL,
	[user_defined_2] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[user_defined_3] [datetime] NULL,
	[user_defined_4] [uniqueidentifier] NULL
) ON [PRIMARY]

GO
