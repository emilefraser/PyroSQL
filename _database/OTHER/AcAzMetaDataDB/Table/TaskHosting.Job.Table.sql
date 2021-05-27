SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[Job]') AND type in (N'U'))
BEGIN
CREATE TABLE [TaskHosting].[Job](
	[JobId] [uniqueidentifier] NOT NULL,
	[IsCancelled] [bit] NOT NULL,
	[InitialInsertTimeUTC] [datetime] NOT NULL,
	[JobType] [int] NOT NULL,
	[InputData] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TaskCount] [int] NOT NULL,
	[CompletedTaskCount] [int] NOT NULL,
	[TracingId] [uniqueidentifier] NULL,
PRIMARY KEY CLUSTERED 
(
	[JobId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[TaskHosting].[Job]') AND name = N'index_job_iscancelled')
CREATE NONCLUSTERED INDEX [index_job_iscancelled] ON [TaskHosting].[Job]
(
	[IsCancelled] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[DF__Job__JobId__2DBCB4E6]') AND type = 'D')
BEGIN
ALTER TABLE [TaskHosting].[Job] ADD  DEFAULT (newid()) FOR [JobId]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[DF__Job__IsCancelled__2EB0D91F]') AND type = 'D')
BEGIN
ALTER TABLE [TaskHosting].[Job] ADD  DEFAULT ((0)) FOR [IsCancelled]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[DF__Job__InitialInse__2FA4FD58]') AND type = 'D')
BEGIN
ALTER TABLE [TaskHosting].[Job] ADD  DEFAULT (getutcdate()) FOR [InitialInsertTimeUTC]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[DF__Job__JobType__30992191]') AND type = 'D')
BEGIN
ALTER TABLE [TaskHosting].[Job] ADD  DEFAULT ((0)) FOR [JobType]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[DF__Job__TaskCount__318D45CA]') AND type = 'D')
BEGIN
ALTER TABLE [TaskHosting].[Job] ADD  DEFAULT ((0)) FOR [TaskCount]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[DF__Job__CompletedTa__32816A03]') AND type = 'D')
BEGIN
ALTER TABLE [TaskHosting].[Job] ADD  DEFAULT ((0)) FOR [CompletedTaskCount]
END
GO
