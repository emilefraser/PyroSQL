SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysutility_mi_dac_execution_statistics_internal](
	[dac_instance_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[database_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[database_id] [int] NOT NULL,
	[date_created] [datetime] NULL,
	[description] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[first_collection_time] [datetimeoffset](7) NULL,
	[last_collection_time] [datetimeoffset](7) NULL,
	[last_upload_time] [datetimeoffset](7) NULL,
	[lifetime_cpu_time_ms] [bigint] NULL,
	[cpu_time_ms_at_last_upload] [bigint] NULL
) ON [PRIMARY]

GO
