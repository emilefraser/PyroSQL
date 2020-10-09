SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[smart_backup_files](
	[backup_path] [nvarchar](260) COLLATE Latin1_General_CI_AS_KS_WS NOT NULL,
	[last_modified_utc] [datetime] NULL,
	[backup_type] [smallint] NULL,
	[expiration_date] [datetime] NULL,
	[user_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[server_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[database_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[backup_size] [numeric](20, 0) NULL,
	[first_lsn] [numeric](25, 0) NULL,
	[last_lsn] [numeric](25, 0) NULL,
	[database_backup_lsn] [numeric](25, 0) NULL,
	[backup_start_date] [datetime] NULL,
	[backup_finish_date] [datetime] NULL,
	[machine_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[last_recovery_fork_id] [uniqueidentifier] NULL,
	[first_recovery_fork_id] [uniqueidentifier] NULL,
	[fork_point_lsn] [numeric](25, 0) NULL,
	[availability_group_guid] [uniqueidentifier] NULL,
	[database_guid] [uniqueidentifier] NULL,
	[status] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
