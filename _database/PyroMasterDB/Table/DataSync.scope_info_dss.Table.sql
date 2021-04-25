SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataSync].[scope_info_dss]') AND type in (N'U'))
BEGIN
CREATE TABLE [DataSync].[scope_info_dss](
	[scope_local_id] [int] IDENTITY(1,1) NOT NULL,
	[scope_id] [uniqueidentifier] NOT NULL,
	[sync_scope_name] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[scope_sync_knowledge] [varbinary](max) NULL,
	[scope_tombstone_cleanup_knowledge] [varbinary](max) NULL,
	[scope_timestamp] [timestamp] NULL,
	[scope_config_id] [uniqueidentifier] NULL,
	[scope_restore_count] [int] NOT NULL,
	[scope_user_comment] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_DataSync.scope_info_dss] PRIMARY KEY CLUSTERED 
(
	[sync_scope_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataSync].[DF__scope_inf__scope__330B79E8]') AND type = 'D')
BEGIN
ALTER TABLE [DataSync].[scope_info_dss] ADD  DEFAULT (newid()) FOR [scope_id]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataSync].[DF__scope_inf__scope__33FF9E21]') AND type = 'D')
BEGIN
ALTER TABLE [DataSync].[scope_info_dss] ADD  DEFAULT ((0)) FOR [scope_restore_count]
END
GO
