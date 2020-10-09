SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[syscollector_collector_types_internal](
	[collector_type_uid] [uniqueidentifier] NOT NULL,
	[name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[parameter_schema] [xml] NULL,
	[parameter_formatter] [xml] NULL,
	[schema_collection] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[collection_package_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[collection_package_folderid] [uniqueidentifier] NOT NULL,
	[upload_package_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[upload_package_folderid] [uniqueidentifier] NOT NULL,
	[is_system] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
