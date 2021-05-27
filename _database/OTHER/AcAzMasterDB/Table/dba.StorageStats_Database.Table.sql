SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[StorageStats_Database]') AND type in (N'U'))
BEGIN
CREATE TABLE [dba].[StorageStats_Database](
	[StorageStats_Database_ID] [int] IDENTITY(1,1) NOT NULL,
	[BatchID] [int] NULL,
	[database_id] [int] NOT NULL,
	[size_database] [int] NULL,
	[state] [tinyint] NULL,
	[state_desc] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[recovery_model] [tinyint] NULL,
	[recovery_model_desc] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[is_auto_create_stats_on] [bit] NULL,
	[is_auto_update_stats_on] [bit] NULL,
	[is_auto_shrink_on] [bit] NULL,
	[is_ansi_padding_on] [bit] NULL,
	[is_fulltext_enabled] [bit] NULL,
	[is_query_store_on] [bit] NULL,
	[is_temporal_history_retention_enabled] [bit] NULL,
	[SqlServerInstanceName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MachineName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NOT NULL
) ON [PRIMARY]
END
GO
