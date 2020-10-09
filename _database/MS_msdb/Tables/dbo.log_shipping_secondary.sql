SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[log_shipping_secondary](
	[secondary_id] [uniqueidentifier] NOT NULL,
	[primary_server] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[primary_database] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[backup_source_directory] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[backup_destination_directory] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[file_retention_period] [int] NOT NULL,
	[copy_job_id] [uniqueidentifier] NOT NULL,
	[restore_job_id] [uniqueidentifier] NOT NULL,
	[monitor_server] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[monitor_server_security_mode] [bit] NOT NULL,
	[user_specified_monitor] [bit] NULL,
	[last_copied_file] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[last_copied_date] [datetime] NULL
) ON [PRIMARY]

GO
