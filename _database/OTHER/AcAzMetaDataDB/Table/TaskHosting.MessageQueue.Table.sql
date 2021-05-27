SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[MessageQueue]') AND type in (N'U'))
BEGIN
CREATE TABLE [TaskHosting].[MessageQueue](
	[MessageId] [uniqueidentifier] NOT NULL,
	[JobId] [uniqueidentifier] NULL,
	[MessageType] [int] NOT NULL,
	[MessageData] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[InitialInsertTimeUTC] [datetime] NOT NULL,
	[InsertTimeUTC] [datetime] NOT NULL,
	[UpdateTimeUTC] [datetime] NULL,
	[ExecTimes] [tinyint] NOT NULL,
	[ResetTimes] [int] NOT NULL,
	[Version] [bigint] NOT NULL,
	[TracingId] [uniqueidentifier] NULL,
	[QueueId] [uniqueidentifier] NULL,
	[WorkerId] [uniqueidentifier] NULL,
PRIMARY KEY CLUSTERED 
(
	[MessageId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[TaskHosting].[MessageQueue]') AND name = N'index_messagequeue_getnextmessage')
CREATE NONCLUSTERED INDEX [index_messagequeue_getnextmessage] ON [TaskHosting].[MessageQueue]
(
	[QueueId] ASC,
	[UpdateTimeUTC] ASC,
	[InsertTimeUTC] ASC,
	[ExecTimes] ASC,
	[Version] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[TaskHosting].[MessageQueue]') AND name = N'index_messagequeue_getnextmessagebytype')
CREATE NONCLUSTERED INDEX [index_messagequeue_getnextmessagebytype] ON [TaskHosting].[MessageQueue]
(
	[QueueId] ASC,
	[MessageType] ASC,
	[UpdateTimeUTC] ASC,
	[InsertTimeUTC] ASC,
	[ExecTimes] ASC,
	[Version] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[TaskHosting].[MessageQueue]') AND name = N'index_messagequeue_jobid')
CREATE NONCLUSTERED INDEX [index_messagequeue_jobid] ON [TaskHosting].[MessageQueue]
(
	[JobId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[DF__MessageQu__Messa__355DD6AE]') AND type = 'D')
BEGIN
ALTER TABLE [TaskHosting].[MessageQueue] ADD  DEFAULT (newid()) FOR [MessageId]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[DF__MessageQu__Messa__37461F20]') AND type = 'D')
BEGIN
ALTER TABLE [TaskHosting].[MessageQueue] ADD  DEFAULT ((0)) FOR [MessageType]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[DF__MessageQu__Initi__383A4359]') AND type = 'D')
BEGIN
ALTER TABLE [TaskHosting].[MessageQueue] ADD  DEFAULT (getutcdate()) FOR [InitialInsertTimeUTC]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[DF__MessageQu__ExecT__392E6792]') AND type = 'D')
BEGIN
ALTER TABLE [TaskHosting].[MessageQueue] ADD  DEFAULT ((0)) FOR [ExecTimes]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[DF__MessageQu__Reset__3A228BCB]') AND type = 'D')
BEGIN
ALTER TABLE [TaskHosting].[MessageQueue] ADD  DEFAULT ((0)) FOR [ResetTimes]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[DF__MessageQu__Versi__3B16B004]') AND type = 'D')
BEGIN
ALTER TABLE [TaskHosting].[MessageQueue] ADD  DEFAULT ((0)) FOR [Version]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[TaskHosting].[FK__MessageQu__JobId__3651FAE7]') AND parent_object_id = OBJECT_ID(N'[TaskHosting].[MessageQueue]'))
ALTER TABLE [TaskHosting].[MessageQueue]  WITH CHECK ADD FOREIGN KEY([JobId])
REFERENCES [TaskHosting].[Job] ([JobId])
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[TaskHosting].[Chk_ExecTimes_GreaterOrEqualZero]') AND parent_object_id = OBJECT_ID(N'[TaskHosting].[MessageQueue]'))
ALTER TABLE [TaskHosting].[MessageQueue]  WITH CHECK ADD  CONSTRAINT [Chk_ExecTimes_GreaterOrEqualZero] CHECK  (([ExecTimes]>=(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[TaskHosting].[Chk_ExecTimes_GreaterOrEqualZero]') AND parent_object_id = OBJECT_ID(N'[TaskHosting].[MessageQueue]'))
ALTER TABLE [TaskHosting].[MessageQueue] CHECK CONSTRAINT [Chk_ExecTimes_GreaterOrEqualZero]
GO
