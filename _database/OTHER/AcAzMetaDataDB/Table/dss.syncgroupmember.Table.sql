SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[syncgroupmember]') AND type in (N'U'))
BEGIN
CREATE TABLE [dss].[syncgroupmember](
	[id] [uniqueidentifier] NOT NULL,
	[name] [dss].[DISPLAY_NAME] NOT NULL,
	[scopename] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[syncgroupid] [uniqueidentifier] NOT NULL,
	[syncdirection] [int] NOT NULL,
	[databaseid] [uniqueidentifier] NOT NULL,
	[memberstate] [int] NOT NULL,
	[hubstate] [int] NOT NULL,
	[memberstate_lastupdated] [datetime] NOT NULL,
	[hubstate_lastupdated] [datetime] NOT NULL,
	[lastsynctime] [datetime] NULL,
	[lastsynctime_zerofailures_member] [datetime] NULL,
	[lastsynctime_zerofailures_hub] [datetime] NULL,
	[jobId] [uniqueidentifier] NULL,
	[hubJobId] [uniqueidentifier] NULL,
	[noinitsync] [bit] NOT NULL,
	[memberhasdata] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_SyncGroupMember_SyncGroupId_DatabaseId] UNIQUE NONCLUSTERED 
(
	[syncgroupid] ASC,
	[databaseid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dss].[syncgroupmember]') AND name = N'index_syncgroupmember_databaseid')
CREATE NONCLUSTERED INDEX [index_syncgroupmember_databaseid] ON [dss].[syncgroupmember]
(
	[databaseid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__syncgroupmem__id__33AA9866]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[syncgroupmember] ADD  DEFAULT (newid()) FOR [id]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__syncgroup__scope__2EE5E349]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[syncgroupmember] ADD  DEFAULT (newid()) FOR [scopename]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__syncgroup__syncd__30CE2BBB]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[syncgroupmember] ADD  DEFAULT ((0)) FOR [syncdirection]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__syncgroup__membe__2DF1BF10]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[syncgroupmember] ADD  DEFAULT ((0)) FOR [memberstate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__syncgroup__hubst__32B6742D]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[syncgroupmember] ADD  DEFAULT ((0)) FOR [hubstate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__syncgroup__membe__2FDA0782]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[syncgroupmember] ADD  DEFAULT (getutcdate()) FOR [memberstate_lastupdated]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__syncgroup__hubst__31C24FF4]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[syncgroupmember] ADD  DEFAULT (getutcdate()) FOR [hubstate_lastupdated]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__syncgroup__noini__2CFD9AD7]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[syncgroupmember] ADD  DEFAULT ((0)) FOR [noinitsync]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dss].[FK__syncmember__datab]') AND parent_object_id = OBJECT_ID(N'[dss].[syncgroupmember]'))
ALTER TABLE [dss].[syncgroupmember]  WITH CHECK ADD  CONSTRAINT [FK__syncmember__datab] FOREIGN KEY([databaseid])
REFERENCES [dss].[userdatabase] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dss].[FK__syncmember__datab]') AND parent_object_id = OBJECT_ID(N'[dss].[syncgroupmember]'))
ALTER TABLE [dss].[syncgroupmember] CHECK CONSTRAINT [FK__syncmember__datab]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dss].[FK__syncmember__syncg]') AND parent_object_id = OBJECT_ID(N'[dss].[syncgroupmember]'))
ALTER TABLE [dss].[syncgroupmember]  WITH CHECK ADD  CONSTRAINT [FK__syncmember__syncg] FOREIGN KEY([syncgroupid])
REFERENCES [dss].[syncgroup] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dss].[FK__syncmember__syncg]') AND parent_object_id = OBJECT_ID(N'[dss].[syncgroupmember]'))
ALTER TABLE [dss].[syncgroupmember] CHECK CONSTRAINT [FK__syncmember__syncg]
GO
