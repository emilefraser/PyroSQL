SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysutility_ucp_mi_volume_space_health_internal](
	[physical_server_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[server_instance_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[volume_device_id] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[health_state] [int] NOT NULL,
	[set_number] [int] NOT NULL,
	[processing_time] [datetimeoffset](7) NOT NULL
) ON [PRIMARY]

GO
