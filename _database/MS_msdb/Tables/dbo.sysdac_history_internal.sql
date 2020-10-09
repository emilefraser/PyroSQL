SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysdac_history_internal](
	[action_id] [int] NOT NULL,
	[sequence_id] [int] NOT NULL,
	[instance_id] [uniqueidentifier] NOT NULL,
	[action_type] [tinyint] NOT NULL,
	[action_type_name]  AS (case [action_type] when (0) then 'deploy' when (1) then 'create' when (2) then 'rename' when (3) then 'register' when (4) then 'create objects' when (5) then 'detach' when (6) then 'delete' when (7) then 'data transfer' when (8) then 'disable constraints' when (9) then 'move data' when (10) then 'enable constraints' when (11) then 'copy permissions' when (12) then 'set readonly' when (13) then 'upgrade' when (14) then 'unregister' when (15) then 'update registration' when (16) then 'set readwrite' when (17) then 'disconnect users'  end),
	[dac_object_type] [tinyint] NOT NULL,
	[dac_object_type_name]  AS (case [dac_object_type] when (0) then 'dacpac' when (1) then 'login' when (2) then 'database'  end),
	[action_status] [tinyint] NOT NULL,
	[action_status_name]  AS (case [action_status] when (0) then 'not started' when (1) then 'pending' when (2) then 'success' when (3) then 'fail' when (4) then 'rollback'  end),
	[required] [bit] NULL,
	[dac_object_name_pretran] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[dac_object_name_posttran] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[sqlscript] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[payload] [varbinary](max) NULL,
	[comments] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[error_string] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_by] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[date_created] [datetime] NOT NULL,
	[date_modified] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
