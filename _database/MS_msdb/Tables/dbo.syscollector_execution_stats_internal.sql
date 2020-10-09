SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[syscollector_execution_stats_internal](
	[log_id] [bigint] NOT NULL,
	[task_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[execution_row_count_in] [int] NULL,
	[execution_row_count_out] [int] NULL,
	[execution_row_count_errors] [int] NULL,
	[execution_time_ms] [int] NULL,
	[log_time] [datetime] NOT NULL
) ON [PRIMARY]

GO
