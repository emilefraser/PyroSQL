SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[syspolicy_object_sets_internal](
	[object_set_id] [int] IDENTITY(1,1) NOT NULL,
	[object_set_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[facet_id] [int] NULL,
	[is_system] [bit] NOT NULL
) ON [PRIMARY]

GO
