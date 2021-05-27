SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[userdatabase]') AND type in (N'U'))
BEGIN
CREATE TABLE [dss].[userdatabase](
	[id] [uniqueidentifier] NOT NULL,
	[server] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[database] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[state] [int] NOT NULL,
	[subscriptionid] [uniqueidentifier] NOT NULL,
	[agentid] [uniqueidentifier] NOT NULL,
	[connection_string] [varbinary](max) NULL,
	[db_schema] [dss].[DB_SCHEMA] NULL,
	[is_on_premise] [bit] NOT NULL,
	[sqlazure_info] [xml] NULL,
	[last_schema_updated] [datetime] NULL,
	[last_tombstonecleanup] [datetime] NULL,
	[region] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[jobId] [uniqueidentifier] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__userdatabase__id__1431ED0D]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[userdatabase] ADD  DEFAULT (newid()) FOR [id]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__userdatab__state__15261146]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[userdatabase] ADD  DEFAULT ((0)) FOR [state]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dss].[FK__userdatab__subsc]') AND parent_object_id = OBJECT_ID(N'[dss].[userdatabase]'))
ALTER TABLE [dss].[userdatabase]  WITH CHECK ADD  CONSTRAINT [FK__userdatab__subsc] FOREIGN KEY([subscriptionid])
REFERENCES [dss].[subscription] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dss].[FK__userdatab__subsc]') AND parent_object_id = OBJECT_ID(N'[dss].[userdatabase]'))
ALTER TABLE [dss].[userdatabase] CHECK CONSTRAINT [FK__userdatab__subsc]
GO
