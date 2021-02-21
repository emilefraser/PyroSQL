SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[DataDictionary_Tables]') AND type in (N'U'))
BEGIN
CREATE TABLE [dba].[DataDictionary_Tables](
	[SchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TableName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TableDescription] [varchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_DataDictionary_Tables] PRIMARY KEY CLUSTERED 
(
	[SchemaName] ASC,
	[TableName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[DF_DataDictionary_TableDescription]') AND type = 'D')
BEGIN
ALTER TABLE [dba].[DataDictionary_Tables] ADD  CONSTRAINT [DF_DataDictionary_TableDescription]  DEFAULT ('') FOR [TableDescription]
END
GO
