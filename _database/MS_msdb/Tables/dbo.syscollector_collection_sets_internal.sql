SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[syscollector_collection_sets_internal](
	[collection_set_id] [int] IDENTITY(1,1) NOT NULL,
	[collection_set_uid] [uniqueidentifier] NOT NULL,
	[schedule_uid] [uniqueidentifier] NULL,
	[name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[name_id] [int] NULL,
	[target] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[is_running] [bit] NOT NULL,
	[proxy_id] [int] NULL,
	[is_system] [bit] NOT NULL,
	[collection_job_id] [uniqueidentifier] NULL,
	[upload_job_id] [uniqueidentifier] NULL,
	[collection_mode] [smallint] NOT NULL,
	[logging_level] [smallint] NOT NULL,
	[description] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[description_id] [int] NULL,
	[days_until_expiration] [smallint] NOT NULL,
	[dump_on_any_error] [bit] NOT NULL,
	[dump_on_codes] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
