SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysutility_mi_cpu_stage_internal](
	[num_processors] [int] NOT NULL,
	[cpu_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[cpu_caption] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[cpu_family_id] [decimal](5, 0) NOT NULL,
	[cpu_architecture_id] [decimal](5, 0) NOT NULL,
	[cpu_max_clock_speed] [decimal](10, 0) NOT NULL,
	[cpu_clock_speed] [decimal](10, 0) NOT NULL,
	[l2_cache_size] [decimal](10, 0) NOT NULL,
	[l3_cache_size] [decimal](10, 0) NOT NULL,
	[instance_processor_usage_start_ticks] [decimal](20, 0) NOT NULL,
	[instance_collect_time_start_ticks] [decimal](20, 0) NOT NULL,
	[computer_processor_idle_start_ticks] [decimal](20, 0) NOT NULL,
	[computer_collect_time_start_ticks] [decimal](20, 0) NOT NULL,
	[instance_processor_usage_end_ticks] [decimal](20, 0) NOT NULL,
	[instance_collect_time_end_ticks] [decimal](20, 0) NOT NULL,
	[computer_processor_idle_end_ticks] [decimal](20, 0) NOT NULL,
	[computer_collect_time_end_ticks] [decimal](20, 0) NOT NULL,
	[server_instance_name]  AS (CONVERT([sysname],serverproperty('ServerName'))),
	[virtual_server_name]  AS (CONVERT([sysname],serverproperty('MachineName'))),
	[physical_server_name]  AS (CONVERT([sysname],serverproperty('ComputerNamePhysicalNetBIOS'))),
	[instance_processor_usage_percentage]  AS (CONVERT([real],case when (0)>([instance_processor_usage_end_ticks]-[instance_processor_usage_start_ticks]) OR (0)>=([instance_collect_time_end_ticks]-[instance_collect_time_start_ticks]) then (0.0) else ((([instance_processor_usage_end_ticks]-[instance_processor_usage_start_ticks])/([instance_collect_time_end_ticks]-[instance_collect_time_start_ticks]))/[num_processors])*(100.0) end)),
	[computer_processor_usage_percentage]  AS (CONVERT([real],case when (0)>([computer_processor_idle_end_ticks]-[computer_processor_idle_start_ticks]) OR (0)>=([computer_collect_time_end_ticks]-[computer_collect_time_start_ticks]) then (0.0) else ((1.0)-([computer_processor_idle_end_ticks]-[computer_processor_idle_start_ticks])/([computer_collect_time_end_ticks]-[computer_collect_time_start_ticks]))*(100.0) end))
) ON [PRIMARY]

GO
