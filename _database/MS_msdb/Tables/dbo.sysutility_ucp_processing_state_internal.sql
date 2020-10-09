SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysutility_ucp_processing_state_internal](
	[latest_processing_time] [datetimeoffset](7) NULL,
	[latest_health_state_id] [int] NULL,
	[next_health_state_id] [int] NULL,
	[id]  AS ((1))
) ON [PRIMARY]

GO
