SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[syssubsystems](
	[subsystem_id] [int] NOT NULL,
	[subsystem] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[description_id] [int] NULL,
	[subsystem_dll] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[agent_exe] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[start_entry_point] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[event_entry_point] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[stop_entry_point] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[max_worker_threads] [int] NULL
) ON [PRIMARY]

GO
