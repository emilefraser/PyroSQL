SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[ScheduleTask]') AND type in (N'U'))
BEGIN
CREATE TABLE [TaskHosting].[ScheduleTask](
	[ScheduleTaskId] [uniqueidentifier] NOT NULL,
	[TaskType] [int] NOT NULL,
	[TaskName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Schedule] [int] NULL,
	[State] [int] NOT NULL,
	[NextRunTime] [datetime] NOT NULL,
	[MessageId] [uniqueidentifier] NULL,
	[TaskInput] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[QueueId] [uniqueidentifier] NOT NULL,
	[TracingId] [uniqueidentifier] NOT NULL,
	[JobId] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ScheduleTaskId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[TaskHosting].[ScheduleTask]') AND name = N'ScheduleTask_MessageId_Index')
CREATE NONCLUSTERED INDEX [ScheduleTask_MessageId_Index] ON [TaskHosting].[ScheduleTask]
(
	[MessageId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[DF__ScheduleT__JobId__41C3AD93]') AND type = 'D')
BEGIN
ALTER TABLE [TaskHosting].[ScheduleTask] ADD  DEFAULT ('00000000-0000-0000-0000-000000000000') FOR [JobId]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[TaskHosting].[FK__ScheduleT__Sched__40CF895A]') AND parent_object_id = OBJECT_ID(N'[TaskHosting].[ScheduleTask]'))
ALTER TABLE [TaskHosting].[ScheduleTask]  WITH CHECK ADD FOREIGN KEY([Schedule])
REFERENCES [TaskHosting].[Schedule] ([ScheduleId])
GO
