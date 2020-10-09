SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[restorehistory](
	[restore_history_id] [int] IDENTITY(1,1) NOT NULL,
	[restore_date] [datetime] NULL,
	[destination_database_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[user_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[backup_set_id] [int] NOT NULL,
	[restore_type] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[replace] [bit] NULL,
	[recovery] [bit] NULL,
	[restart] [bit] NULL,
	[stop_at] [datetime] NULL,
	[device_count] [tinyint] NULL,
	[stop_at_mark_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[stop_before] [bit] NULL
) ON [PRIMARY]

GO
