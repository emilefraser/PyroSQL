SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysutility_ucp_dacs_stub](
	[dac_id] [int] IDENTITY(1,1) NOT NULL,
	[physical_server_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[server_instance_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[dac_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[dac_deploy_date] [datetime] NULL,
	[dac_description] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[urn] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[powershell_path] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[processing_time] [datetimeoffset](7) NULL,
	[batch_time] [datetimeoffset](7) NULL,
	[dac_percent_total_cpu_utilization] [real] NULL
) ON [PRIMARY]

GO
