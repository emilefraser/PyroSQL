SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DTA_reports_table](
	[TableID] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseID] [int] NOT NULL,
	[SchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TableName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsView] [bit] NOT NULL
) ON [PRIMARY]

GO
