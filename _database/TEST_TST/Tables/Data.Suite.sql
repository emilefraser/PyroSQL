SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Data].[Suite](
	[SuiteId] [int] IDENTITY(1,1) NOT NULL,
	[TestSessionId] [int] NOT NULL,
	[SchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SuiteName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
