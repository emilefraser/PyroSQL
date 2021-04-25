SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[config].[Suite]') AND type in (N'U'))
BEGIN
CREATE TABLE [config].[Suite](
	[SuiteId] [int] IDENTITY(1,1) NOT NULL,
	[TestSessionId] [int] NOT NULL,
	[SchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SuiteName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_Suite] PRIMARY KEY CLUSTERED 
(
	[SuiteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UK_Suite_TestSessionId_SuiteName] UNIQUE NONCLUSTERED 
(
	[TestSessionId] ASC,
	[SchemaName] ASC,
	[SuiteName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[config].[Suite]') AND name = N'IX_Suite_TestSessionId_SuiteId')
CREATE NONCLUSTERED INDEX [IX_Suite_TestSessionId_SuiteId] ON [config].[Suite]
(
	[TestSessionId] ASC,
	[SuiteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[config].[FK_Suite_TestSessionId]') AND parent_object_id = OBJECT_ID(N'[config].[Suite]'))
ALTER TABLE [config].[Suite]  WITH CHECK ADD  CONSTRAINT [FK_Suite_TestSessionId] FOREIGN KEY([TestSessionId])
REFERENCES [config].[TestSession] ([TestSessionId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[config].[FK_Suite_TestSessionId]') AND parent_object_id = OBJECT_ID(N'[config].[Suite]'))
ALTER TABLE [config].[Suite] CHECK CONSTRAINT [FK_Suite_TestSessionId]
GO
