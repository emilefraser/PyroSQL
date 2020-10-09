SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysdbmaintplan_history](
	[sequence_id] [int] IDENTITY(1,1) NOT NULL,
	[plan_id] [uniqueidentifier] NOT NULL,
	[plan_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[database_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[server_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[activity] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[succeeded] [bit] NOT NULL,
	[end_time] [datetime] NOT NULL,
	[duration] [int] NULL,
	[start_time]  AS (dateadd(second, -[duration],[end_time])),
	[error_number] [int] NOT NULL,
	[message] [nvarchar](512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
