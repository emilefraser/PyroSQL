SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dm].[VaultSpeedAttributeRelation]') AND type in (N'U'))
BEGIN
CREATE TABLE [dm].[VaultSpeedAttributeRelation](
	[datavault] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[src_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[src_physical_schema] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[stg_physical_schema] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dv_physical_schema] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[src_table_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[stg_table_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dv_table_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[src_column_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[src_column_order] [smallint] NULL,
	[stg_column_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dv_column_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dv_column_type] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
END
GO
