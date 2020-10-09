SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[syscollector_collection_items_internal](
	[collection_set_id] [int] NOT NULL,
	[collection_item_id] [int] IDENTITY(1,1) NOT NULL,
	[collector_type_uid] [uniqueidentifier] NOT NULL,
	[name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[name_id] [int] NULL,
	[frequency] [int] NOT NULL,
	[parameters] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
