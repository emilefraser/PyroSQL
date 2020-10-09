SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[syspolicy_target_set_levels_internal](
	[target_set_level_id] [int] IDENTITY(1,1) NOT NULL,
	[target_set_id] [int] NOT NULL,
	[type_skeleton] [nvarchar](440) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[condition_id] [int] NULL,
	[level_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
