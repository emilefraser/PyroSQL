SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[log_shipping_primaries](
	[primary_id] [int] IDENTITY(1,1) NOT NULL,
	[primary_server_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[primary_database_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[maintenance_plan_id] [uniqueidentifier] NULL,
	[backup_threshold] [int] NOT NULL,
	[threshold_alert] [int] NOT NULL,
	[threshold_alert_enabled] [bit] NOT NULL,
	[last_backup_filename] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[last_updated] [datetime] NULL,
	[planned_outage_start_time] [int] NOT NULL,
	[planned_outage_end_time] [int] NOT NULL,
	[planned_outage_weekday_mask] [int] NOT NULL,
	[source_directory] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
