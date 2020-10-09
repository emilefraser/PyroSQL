SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [STORE].[StorageStats_Index](
	[StorageStats_IndexID] [int] IDENTITY(1,1) NOT NULL,
	[BatchID] [int] NOT NULL,
	[index_id] [int] NOT NULL,
	[index_type] [tinyint] NOT NULL,
	[type_desc] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[fill_factor] [tinyint] NULL,
	[is_unique] [bit] NULL,
	[is_padded] [bit] NULL,
	[size_index_total] [float] NULL,
	[size_index_used] [float] NULL,
	[size_index_unused] [float] NULL,
	[table_id] [int] NOT NULL,
	[schema_id] [int] NOT NULL,
	[database_id] [int] NOT NULL,
	[CreatedDT] [datetime] NOT NULL
) ON [PRIMARY]

GO
