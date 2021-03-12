SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[syncgroup]') AND type in (N'U'))
BEGIN
CREATE TABLE [dss].[syncgroup](
	[id] [uniqueidentifier] NOT NULL,
	[name] [dss].[DISPLAY_NAME] NULL,
	[subscriptionid] [uniqueidentifier] NULL,
	[schema_description] [xml] NULL,
	[state] [int] NULL,
	[hub_memberid] [uniqueidentifier] NULL,
	[conflict_resolution_policy] [int] NOT NULL,
	[sync_interval] [int] NOT NULL,
	[sync_enabled] [bit] NOT NULL,
	[lastupdatetime] [datetime] NULL,
	[ocsschemadefinition] [dss].[DB_SCHEMA] NULL,
	[hubhasdata] [bit] NULL,
	[ConflictLoggingEnabled] [bit] NOT NULL,
	[ConflictTableRetentionInDays] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dss].[syncgroup]') AND name = N'index_syncgroup_hub_memberid')
CREATE NONCLUSTERED INDEX [index_syncgroup_hub_memberid] ON [dss].[syncgroup]
(
	[hub_memberid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__syncgroup__id__1BD30ED5]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[syncgroup] ADD  DEFAULT (newid()) FOR [id]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__syncgroup__state__1ADEEA9C]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[syncgroup] ADD  DEFAULT ((0)) FOR [state]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__syncgroup__sync___1CC7330E]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[syncgroup] ADD  DEFAULT ((1)) FOR [sync_enabled]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__syncgroup__Confl__1DBB5747]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[syncgroup] ADD  DEFAULT ((0)) FOR [ConflictLoggingEnabled]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__syncgroup__Confl__1EAF7B80]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[syncgroup] ADD  DEFAULT ((30)) FOR [ConflictTableRetentionInDays]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dss].[FK__syncgroup__hub_m]') AND parent_object_id = OBJECT_ID(N'[dss].[syncgroup]'))
ALTER TABLE [dss].[syncgroup]  WITH CHECK ADD  CONSTRAINT [FK__syncgroup__hub_m] FOREIGN KEY([hub_memberid])
REFERENCES [dss].[userdatabase] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dss].[FK__syncgroup__hub_m]') AND parent_object_id = OBJECT_ID(N'[dss].[syncgroup]'))
ALTER TABLE [dss].[syncgroup] CHECK CONSTRAINT [FK__syncgroup__hub_m]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dss].[FK__syncgroup__subsc]') AND parent_object_id = OBJECT_ID(N'[dss].[syncgroup]'))
ALTER TABLE [dss].[syncgroup]  WITH CHECK ADD  CONSTRAINT [FK__syncgroup__subsc] FOREIGN KEY([subscriptionid])
REFERENCES [dss].[subscription] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dss].[FK__syncgroup__subsc]') AND parent_object_id = OBJECT_ID(N'[dss].[syncgroup]'))
ALTER TABLE [dss].[syncgroup] CHECK CONSTRAINT [FK__syncgroup__subsc]
GO
