SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MSdbms_datatype_mapping](
	[datatype_mapping_id] [int] IDENTITY(1,1) NOT NULL,
	[map_id] [int] NOT NULL,
	[dest_datatype_id] [int] NOT NULL,
	[dest_precision] [bigint] NULL,
	[dest_scale] [int] NULL,
	[dest_length] [bigint] NULL,
	[dest_nullable] [bit] NULL,
	[dest_createparams] [int] NULL,
	[dataloss] [bit] NOT NULL
) ON [PRIMARY]

GO
