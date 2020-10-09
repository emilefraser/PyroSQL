SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[syspolicy_execution_internal](
	[policy_id] [int] NULL,
	[synchronous] [bit] NULL,
	[event_data] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
