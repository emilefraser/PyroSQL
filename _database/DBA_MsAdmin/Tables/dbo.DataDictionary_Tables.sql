SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DataDictionary_Tables](
	[SchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TableName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TableDescription] [varchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
