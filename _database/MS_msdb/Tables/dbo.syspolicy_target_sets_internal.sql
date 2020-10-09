SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[syspolicy_target_sets_internal](
	[target_set_id] [int] IDENTITY(1,1) NOT NULL,
	[object_set_id] [int] NOT NULL,
	[type_skeleton] [nvarchar](440) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[type] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[enabled] [bit] NOT NULL
) ON [PRIMARY]

GO
