SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysutility_mi_session_statistics_internal](
	[collection_time] [datetimeoffset](7) NOT NULL,
	[session_id] [int] NOT NULL,
	[dac_instance_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[database_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[login_time] [datetime] NOT NULL,
	[cumulative_cpu_ms] [int] NOT NULL
) ON [PRIMARY]

GO
