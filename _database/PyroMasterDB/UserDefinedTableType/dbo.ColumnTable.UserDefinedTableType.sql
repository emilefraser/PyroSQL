IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ColumnTable' AND ss.name = N'dbo')
CREATE TYPE [dbo].[ColumnTable] AS TABLE(
	[ordinal_position] [int] NOT NULL,
	[column_name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[column_value] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[data_type] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[max_len] [int] NULL,
	[column_type_id] [int] NULL,
	[is_nullable] [bit] NULL,
	[prefix] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[entity_name] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[foreign_column_name] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[foreign_sur_pkey] [int] NULL,
	[numeric_precision] [int] NULL,
	[numeric_scale] [int] NULL,
	[part_of_unique_index] [bit] NULL,
	[identity] [bit] NULL,
	[src_mapping] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	PRIMARY KEY CLUSTERED 
(
	[ordinal_position] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
