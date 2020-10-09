SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[syscollector_execution_log_internal](
	[log_id] [bigint] IDENTITY(1,1) NOT NULL,
	[parent_log_id] [bigint] NULL,
	[collection_set_id] [int] NOT NULL,
	[collection_item_id] [int] NULL,
	[start_time] [datetime] NOT NULL,
	[last_iteration_time] [datetime] NULL,
	[finish_time] [datetime] NULL,
	[runtime_execution_mode] [smallint] NULL,
	[status] [smallint] NOT NULL,
	[operator] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[package_id] [uniqueidentifier] NULL,
	[package_execution_id] [uniqueidentifier] NULL,
	[failure_message] [nvarchar](2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
