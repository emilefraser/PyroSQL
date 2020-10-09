SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Data].[Test](
	[TestId] [int] IDENTITY(1,1) NOT NULL,
	[TestSessionId] [int] NOT NULL,
	[SuiteId] [int] NOT NULL,
	[SchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SProcName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SProcType] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
