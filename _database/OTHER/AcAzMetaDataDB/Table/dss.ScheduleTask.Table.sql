SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[ScheduleTask]') AND type in (N'U'))
BEGIN
CREATE TABLE [dss].[ScheduleTask](
	[Id] [uniqueidentifier] NOT NULL,
	[SyncGroupId] [uniqueidentifier] NOT NULL,
	[Interval] [bigint] NOT NULL,
	[LastUpdate] [datetime] NOT NULL,
	[State] [tinyint] NOT NULL,
	[ExpirationTime] [datetime] NULL,
	[PopReceipt] [uniqueidentifier] NULL,
	[DequeueCount] [tinyint] NOT NULL,
	[Type] [int] NOT NULL,
 CONSTRAINT [PK_ScheduleTask] PRIMARY KEY CLUSTERED 
(
	[SyncGroupId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__ScheduleTask__Id__19EAC663]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[ScheduleTask] ADD  DEFAULT (newid()) FOR [Id]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__ScheduleT__State__18F6A22A]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[ScheduleTask] ADD  DEFAULT ((0)) FOR [State]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__ScheduleT__Deque__18027DF1]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[ScheduleTask] ADD  DEFAULT ((0)) FOR [DequeueCount]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__ScheduleTa__Type__170E59B8]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[ScheduleTask] ADD  DEFAULT ((0)) FOR [Type]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dss].[FK__ScheduleT__SyncG]') AND parent_object_id = OBJECT_ID(N'[dss].[ScheduleTask]'))
ALTER TABLE [dss].[ScheduleTask]  WITH CHECK ADD  CONSTRAINT [FK__ScheduleT__SyncG] FOREIGN KEY([SyncGroupId])
REFERENCES [dss].[syncgroup] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dss].[FK__ScheduleT__SyncG]') AND parent_object_id = OBJECT_ID(N'[dss].[ScheduleTask]'))
ALTER TABLE [dss].[ScheduleTask] CHECK CONSTRAINT [FK__ScheduleT__SyncG]
GO
