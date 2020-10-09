SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[syspolicy_conditions_internal](
	[condition_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[date_created] [datetime] NULL,
	[description] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[created_by] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[modified_by] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[date_modified] [datetime] NULL,
	[facet_id] [int] NULL,
	[expression] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[is_name_condition] [smallint] NULL,
	[obj_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[is_system] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
