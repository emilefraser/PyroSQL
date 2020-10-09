SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[log_shipping_monitor_error_detail](
	[agent_id] [uniqueidentifier] NOT NULL,
	[agent_type] [tinyint] NOT NULL,
	[session_id] [int] NOT NULL,
	[database_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sequence_number] [int] NOT NULL,
	[log_time] [datetime] NOT NULL,
	[log_time_utc] [datetime] NOT NULL,
	[message] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[source] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[help_url] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO