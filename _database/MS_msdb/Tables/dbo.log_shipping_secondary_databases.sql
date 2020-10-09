SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[log_shipping_secondary_databases](
	[secondary_database] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[secondary_id] [uniqueidentifier] NOT NULL,
	[restore_delay] [int] NOT NULL,
	[restore_all] [bit] NOT NULL,
	[restore_mode] [bit] NOT NULL,
	[disconnect_users] [bit] NOT NULL,
	[block_size] [int] NULL,
	[buffer_count] [int] NULL,
	[max_transfer_size] [int] NULL,
	[last_restored_file] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[last_restored_date] [datetime] NULL
) ON [PRIMARY]

GO
