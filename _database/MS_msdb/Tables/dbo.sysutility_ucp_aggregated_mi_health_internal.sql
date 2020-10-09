SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysutility_ucp_aggregated_mi_health_internal](
	[mi_count] [int] NOT NULL,
	[mi_healthy_count] [int] NOT NULL,
	[mi_unhealthy_count] [int] NOT NULL,
	[mi_over_utilize_count] [int] NOT NULL,
	[mi_under_utilize_count] [int] NOT NULL,
	[mi_on_over_utilized_computer_count] [int] NOT NULL,
	[mi_on_under_utilized_computer_count] [int] NOT NULL,
	[mi_with_files_on_over_utilized_volume_count] [int] NOT NULL,
	[mi_with_files_on_under_utilized_volume_count] [int] NOT NULL,
	[mi_with_over_utilized_file_count] [int] NOT NULL,
	[mi_with_under_utilized_file_count] [int] NOT NULL,
	[mi_with_over_utilized_processor_count] [int] NOT NULL,
	[mi_with_under_utilized_processor_count] [int] NOT NULL,
	[set_number] [int] NOT NULL
) ON [PRIMARY]

GO
