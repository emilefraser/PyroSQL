SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[config].[Test]') AND type in (N'U'))
BEGIN
CREATE TABLE [config].[Test](
	[TestId] [int] IDENTITY(1,1) NOT NULL,
	[TestSessionId] [int] NOT NULL,
	[SuiteId] [int] NOT NULL,
	[SchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SProcName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SProcType] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_Test] PRIMARY KEY CLUSTERED 
(
	[TestId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UK_Test_SuiteId_SchemaName_SProcName] UNIQUE NONCLUSTERED 
(
	[SuiteId] ASC,
	[SchemaName] ASC,
	[SProcName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UK_Test_TestSessionId_SchemaName_SProcName] UNIQUE NONCLUSTERED 
(
	[TestSessionId] ASC,
	[SchemaName] ASC,
	[SProcName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[config].[Test]') AND name = N'IX_Test_SuiteId_SProcName')
CREATE NONCLUSTERED INDEX [IX_Test_SuiteId_SProcName] ON [config].[Test]
(
	[SuiteId] ASC,
	[SProcName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[config].[Test]') AND name = N'IX_Test_TestSessionId_SProcName')
CREATE NONCLUSTERED INDEX [IX_Test_TestSessionId_SProcName] ON [config].[Test]
(
	[TestSessionId] ASC,
	[SProcName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[config].[FK_Test_SuiteId]') AND parent_object_id = OBJECT_ID(N'[config].[Test]'))
ALTER TABLE [config].[Test]  WITH CHECK ADD  CONSTRAINT [FK_Test_SuiteId] FOREIGN KEY([SuiteId])
REFERENCES [config].[Suite] ([SuiteId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[config].[FK_Test_SuiteId]') AND parent_object_id = OBJECT_ID(N'[config].[Test]'))
ALTER TABLE [config].[Test] CHECK CONSTRAINT [FK_Test_SuiteId]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[config].[CK_Test_SProcType]') AND parent_object_id = OBJECT_ID(N'[config].[Test]'))
ALTER TABLE [config].[Test]  WITH CHECK ADD  CONSTRAINT [CK_Test_SProcType] CHECK  (([SProcType]='SetupS' OR [SProcType]='TeardownS' OR [SProcType]='Setup' OR [SProcType]='Teardown' OR [SProcType]='Test'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[config].[CK_Test_SProcType]') AND parent_object_id = OBJECT_ID(N'[config].[Test]'))
ALTER TABLE [config].[Test] CHECK CONSTRAINT [CK_Test_SProcType]
GO
