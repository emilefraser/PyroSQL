SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[log_shipping_secondaries](
	[primary_id] [int] NULL,
	[secondary_server_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[secondary_database_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[last_copied_filename] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[last_loaded_filename] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[last_copied_last_updated] [datetime] NULL,
	[last_loaded_last_updated] [datetime] NULL,
	[secondary_plan_id] [uniqueidentifier] NULL,
	[copy_enabled] [bit] NULL,
	[load_enabled] [bit] NULL,
	[out_of_sync_threshold] [int] NULL,
	[threshold_alert] [int] NULL,
	[threshold_alert_enabled] [bit] NULL,
	[planned_outage_start_time] [int] NULL,
	[planned_outage_end_time] [int] NULL,
	[planned_outage_weekday_mask] [int] NULL,
	[allow_role_change] [bit] NULL
) ON [PRIMARY]

GO
