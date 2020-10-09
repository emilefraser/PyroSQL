SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[syspolicy_policies_internal](
	[policy_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[condition_id] [int] NOT NULL,
	[root_condition_id] [int] NULL,
	[date_created] [datetime] NOT NULL,
	[execution_mode] [int] NOT NULL,
	[policy_category_id] [int] NULL,
	[schedule_uid] [uniqueidentifier] NULL,
	[description] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[help_text] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[help_link] [nvarchar](2083) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[object_set_id] [int] NULL,
	[is_enabled] [bit] NOT NULL,
	[job_id] [uniqueidentifier] NULL,
	[created_by] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[modified_by] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[date_modified] [datetime] NULL,
	[is_system] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
