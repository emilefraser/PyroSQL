SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[syspolicy_system_health_state_internal](
	[health_state_id] [bigint] IDENTITY(1,1) NOT NULL,
	[policy_id] [int] NOT NULL,
	[last_run_date] [datetime] NOT NULL,
	[target_query_expression_with_id] [nvarchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[target_query_expression] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[result] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
