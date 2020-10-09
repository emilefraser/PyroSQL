SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[syspolicy_policy_execution_history_internal](
	[history_id] [bigint] IDENTITY(1,1) NOT NULL,
	[policy_id] [int] NOT NULL,
	[start_date] [datetime] NOT NULL,
	[end_date] [datetime] NULL,
	[result] [bit] NOT NULL,
	[is_full_run] [bit] NOT NULL,
	[exception_message] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[exception] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
