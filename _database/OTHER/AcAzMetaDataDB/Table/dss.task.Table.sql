SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[task]') AND type in (N'U'))
BEGIN
CREATE TABLE [dss].[task](
	[id] [uniqueidentifier] NOT NULL,
	[actionid] [uniqueidentifier] NOT NULL,
	[taskNumber] [bigint] IDENTITY(1,1) NOT NULL,
	[lastheartbeat] [datetime] NULL,
	[state] [int] NULL,
	[type] [int] NULL,
	[agentid] [uniqueidentifier] NULL,
	[owning_instanceid] [uniqueidentifier] NULL,
	[creationtime] [datetime] NULL,
	[pickuptime] [datetime] NULL,
	[completedtime] [datetime] NULL,
	[request] [dss].[TASK_REQUEST_RESPONSE] NULL,
	[response] [dss].[TASK_REQUEST_RESPONSE] NULL,
	[priority] [int] NULL,
	[retry_count] [int] NOT NULL,
	[dependency_count] [int] NOT NULL,
	[version] [bigint] NOT NULL,
	[lastresettime] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dss].[task]') AND name = N'index_task_actionid')
CREATE NONCLUSTERED INDEX [index_task_actionid] ON [dss].[task]
(
	[actionid] ASC
)
INCLUDE([id],[state]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dss].[task]') AND name = N'index_task_agentid_state')
CREATE NONCLUSTERED INDEX [index_task_agentid_state] ON [dss].[task]
(
	[agentid] ASC,
	[state] ASC
)
INCLUDE([type]) 
WHERE ([state]=(0))
WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dss].[task]') AND name = N'index_task_completedtime')
CREATE NONCLUSTERED INDEX [index_task_completedtime] ON [dss].[task]
(
	[completedtime] ASC
)
INCLUDE([actionid]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dss].[task]') AND name = N'index_task_gettask')
CREATE NONCLUSTERED INDEX [index_task_gettask] ON [dss].[task]
(
	[state] ASC,
	[agentid] ASC,
	[dependency_count] ASC,
	[priority] ASC,
	[creationtime] ASC
)
INCLUDE([owning_instanceid],[version]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dss].[task]') AND name = N'index_task_state')
CREATE NONCLUSTERED INDEX [index_task_state] ON [dss].[task]
(
	[state] ASC,
	[completedtime] ASC
)
INCLUDE([type]) 
WHERE ([state]=(2))
WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dss].[task]') AND name = N'index_task_state_lastheartbeat')
CREATE NONCLUSTERED INDEX [index_task_state_lastheartbeat] ON [dss].[task]
(
	[lastheartbeat] ASC,
	[state] ASC
)
INCLUDE([id],[owning_instanceid]) 
WHERE ([state]<(0))
WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__task__id__133DC8D4]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[task] ADD  DEFAULT (newid()) FOR [id]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__task__state__1249A49B]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[task] ADD  DEFAULT ((0)) FOR [state]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__task__creationti__10615C29]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[task] ADD  DEFAULT (getutcdate()) FOR [creationtime]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__task__priority__0F6D37F0]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[task] ADD  DEFAULT ((100)) FOR [priority]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__task__retry_coun__0D84EF7E]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[task] ADD  DEFAULT ((0)) FOR [retry_count]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__task__dependency__0E7913B7]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[task] ADD  DEFAULT ((0)) FOR [dependency_count]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__task__version__11558062]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[task] ADD  DEFAULT ((0)) FOR [version]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dss].[FK__task__actionid]') AND parent_object_id = OBJECT_ID(N'[dss].[task]'))
ALTER TABLE [dss].[task]  WITH CHECK ADD  CONSTRAINT [FK__task__actionid] FOREIGN KEY([actionid])
REFERENCES [dss].[action] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dss].[FK__task__actionid]') AND parent_object_id = OBJECT_ID(N'[dss].[task]'))
ALTER TABLE [dss].[task] CHECK CONSTRAINT [FK__task__actionid]
GO
