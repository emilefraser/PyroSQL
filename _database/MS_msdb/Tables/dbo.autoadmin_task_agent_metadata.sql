SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[autoadmin_task_agent_metadata](
	[task_agent_guid] [uniqueidentifier] NOT NULL,
	[autoadmin_id] [bigint] NOT NULL,
	[last_modified] [datetime] NOT NULL,
	[task_agent_data] [xml] NULL,
	[schema_version] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
