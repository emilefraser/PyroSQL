SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MSdbms_map](
	[map_id] [int] IDENTITY(1,1) NOT NULL,
	[src_dbms_id] [int] NOT NULL,
	[dest_dbms_id] [int] NOT NULL,
	[src_datatype_id] [int] NOT NULL,
	[src_len_min] [bigint] NULL,
	[src_len_max] [bigint] NULL,
	[src_prec_min] [bigint] NULL,
	[src_prec_max] [bigint] NULL,
	[src_scale_min] [bigint] NULL,
	[src_scale_max] [bigint] NULL,
	[src_nullable] [bit] NULL,
	[default_datatype_mapping_id] [int] NULL
) ON [PRIMARY]

GO
