SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[DataDictionary_Fields]') AND type in (N'U'))
BEGIN
CREATE TABLE [dba].[DataDictionary_Fields](
	[SchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TableName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FieldName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FieldDescription] [varchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_DataDictionary_Fields] PRIMARY KEY CLUSTERED 
(
	[SchemaName] ASC,
	[TableName] ASC,
	[FieldName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[DF_DataDictionary_FieldDescription]') AND type = 'D')
BEGIN
ALTER TABLE [dba].[DataDictionary_Fields] ADD  CONSTRAINT [DF_DataDictionary_FieldDescription]  DEFAULT ('') FOR [FieldDescription]
END
GO
