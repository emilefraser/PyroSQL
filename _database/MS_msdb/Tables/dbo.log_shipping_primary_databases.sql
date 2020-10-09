SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[log_shipping_primary_databases](
	[primary_id] [uniqueidentifier] NOT NULL,
	[primary_database] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[backup_directory] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[backup_share] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[backup_retention_period] [int] NOT NULL,
	[backup_job_id] [uniqueidentifier] NOT NULL,
	[monitor_server] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[user_specified_monitor] [bit] NULL,
	[monitor_server_security_mode] [bit] NOT NULL,
	[last_backup_file] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[last_backup_date] [datetime] NULL,
	[backup_compression] [tinyint] NOT NULL
) ON [PRIMARY]

GO
