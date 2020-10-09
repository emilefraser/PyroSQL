SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[syspolicy_policy_execution_history_details_internal](
	[detail_id] [bigint] IDENTITY(1,1) NOT NULL,
	[history_id] [bigint] NOT NULL,
	[target_query_expression] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[target_query_expression_with_id] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[execution_date] [datetime] NOT NULL,
	[result] [bit] NOT NULL,
	[result_detail] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[exception_message] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[exception] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
