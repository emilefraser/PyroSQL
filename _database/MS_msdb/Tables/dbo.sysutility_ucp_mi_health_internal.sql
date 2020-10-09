SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysutility_ucp_mi_health_internal](
	[mi_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[is_volume_space_over_utilized] [int] NOT NULL,
	[is_volume_space_under_utilized] [int] NOT NULL,
	[is_computer_processor_over_utilized] [int] NOT NULL,
	[is_computer_processor_under_utilized] [int] NOT NULL,
	[is_file_space_over_utilized] [int] NOT NULL,
	[is_file_space_under_utilized] [int] NOT NULL,
	[is_mi_processor_over_utilized] [int] NOT NULL,
	[is_mi_processor_under_utilized] [int] NOT NULL,
	[is_policy_overridden] [bit] NOT NULL,
	[set_number] [int] NOT NULL,
	[processing_time] [datetimeoffset](7) NOT NULL
) ON [PRIMARY]

GO