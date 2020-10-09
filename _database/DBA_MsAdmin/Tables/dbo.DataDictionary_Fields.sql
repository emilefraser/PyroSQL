SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DataDictionary_Fields](
	[SchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TableName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FieldName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FieldDescription] [varchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
