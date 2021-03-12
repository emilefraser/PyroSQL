SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[action]') AND type in (N'U'))
BEGIN
CREATE TABLE [dss].[action](
	[id] [uniqueidentifier] NOT NULL,
	[syncgroupid] [uniqueidentifier] NULL,
	[type] [int] NOT NULL,
	[state] [int] NOT NULL,
	[creationtime] [datetime] NULL,
	[lastupdatetime] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dss].[action]') AND name = N'index_action_state_lastupdatetime')
CREATE NONCLUSTERED INDEX [index_action_state_lastupdatetime] ON [dss].[action]
(
	[state] ASC,
	[lastupdatetime] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__action__id__2374309D]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[action] ADD  DEFAULT (newid()) FOR [id]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__action__state__22800C64]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[action] ADD  DEFAULT ((0)) FOR [state]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__action__creation__246854D6]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[action] ADD  DEFAULT (getutcdate()) FOR [creationtime]
END
GO
