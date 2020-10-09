SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[syspolicy_facet_events](
	[management_facet_id] [int] NOT NULL,
	[event_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[target_type] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[target_type_alias] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
