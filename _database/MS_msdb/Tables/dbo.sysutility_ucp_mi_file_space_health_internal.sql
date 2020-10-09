SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysutility_ucp_mi_file_space_health_internal](
	[server_instance_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[database_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[fg_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[over_utilized_count] [int] NOT NULL,
	[under_utilized_count] [int] NOT NULL,
	[file_type] [int] NOT NULL,
	[set_number] [int] NOT NULL,
	[processing_time] [datetimeoffset](7) NOT NULL
) ON [PRIMARY]

GO
