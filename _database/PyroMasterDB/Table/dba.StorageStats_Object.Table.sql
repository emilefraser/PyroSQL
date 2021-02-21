SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[StorageStats_Object]') AND type in (N'U'))
BEGIN
CREATE TABLE [dba].[StorageStats_Object](
	[StorageStats_Object_ID] [int] IDENTITY(1,1) NOT NULL,
	[BatchID] [int] NOT NULL,
	[object_id] [int] NOT NULL,
	[object_type] [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[object_type_desc] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[large_value_types_out_of_row] [bit] NULL,
	[durability] [tinyint] NULL,
	[durability_desc] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[temporal_type] [tinyint] NULL,
	[temporal_type_desc] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[is_external] [bit] NOT NULL,
	[history_retention_period] [int] NULL,
	[column_count] [int] NOT NULL,
	[row_count] [bigint] NULL,
	[text_in_row_limit] [int] NULL,
	[size_table_total] [bigint] NULL,
	[size_table_used] [bigint] NULL,
	[size_table_unused] [bigint] NULL,
	[allocation_type] [tinyint] NOT NULL,
	[allocation_type_desc] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[schema_id] [int] NULL,
	[database_id] [int] NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL
) ON [PRIMARY]
END
GO
