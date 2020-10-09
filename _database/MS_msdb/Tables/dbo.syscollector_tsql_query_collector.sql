SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[syscollector_tsql_query_collector](
	[collection_set_uid] [uniqueidentifier] NOT NULL,
	[collection_set_id] [int] NOT NULL,
	[collection_item_id] [int] NOT NULL,
	[collection_package_id] [uniqueidentifier] NOT NULL,
	[upload_package_id] [uniqueidentifier] NOT NULL
) ON [PRIMARY]

GO
