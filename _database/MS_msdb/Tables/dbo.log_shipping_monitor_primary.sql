SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[log_shipping_monitor_primary](
	[primary_id] [uniqueidentifier] NOT NULL,
	[primary_server] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[primary_database] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[backup_threshold] [int] NOT NULL,
	[threshold_alert] [int] NOT NULL,
	[threshold_alert_enabled] [bit] NOT NULL,
	[last_backup_file] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[last_backup_date] [datetime] NULL,
	[last_backup_date_utc] [datetime] NULL,
	[history_retention_period] [int] NOT NULL
) ON [PRIMARY]

GO
