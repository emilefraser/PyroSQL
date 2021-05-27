SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[config].[SystemErrorLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [config].[SystemErrorLog](
	[LogEntryId] [int] IDENTITY(1,1) NOT NULL,
	[TestSessionId] [int] NOT NULL,
	[CreatedTime] [datetime] NOT NULL,
	[LogMessage] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_SystemErrorLog] PRIMARY KEY CLUSTERED 
(
	[LogEntryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[config].[SystemErrorLog]') AND name = N'IX_SystemErrorLog_TestSessionId')
CREATE NONCLUSTERED INDEX [IX_SystemErrorLog_TestSessionId] ON [config].[SystemErrorLog]
(
	[TestSessionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[config].[DF__SystemErr__Creat__51AFFC99]') AND type = 'D')
BEGIN
ALTER TABLE [config].[SystemErrorLog] ADD  DEFAULT (getdate()) FOR [CreatedTime]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[config].[FK_SystemErrorLog_TestSessionId]') AND parent_object_id = OBJECT_ID(N'[config].[SystemErrorLog]'))
ALTER TABLE [config].[SystemErrorLog]  WITH CHECK ADD  CONSTRAINT [FK_SystemErrorLog_TestSessionId] FOREIGN KEY([TestSessionId])
REFERENCES [config].[TestSession] ([TestSessionId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[config].[FK_SystemErrorLog_TestSessionId]') AND parent_object_id = OBJECT_ID(N'[config].[SystemErrorLog]'))
ALTER TABLE [config].[SystemErrorLog] CHECK CONSTRAINT [FK_SystemErrorLog_TestSessionId]
GO
