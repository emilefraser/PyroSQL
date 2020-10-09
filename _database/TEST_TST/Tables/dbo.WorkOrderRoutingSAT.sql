SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[WorkOrderRoutingSAT](
	[WorkOrderRoutingVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[PlannedCost] [money] NOT NULL,
	[ScheduledEndDate] [datetime] NOT NULL,
	[ScheduledStartDate] [datetime] NOT NULL,
	[ActualCost] [money] NULL,
	[ActualEndDate] [datetime] NULL,
	[ActualResourceHours] [decimal](18, 0) NULL,
	[ActualStartDate] [datetime] NULL
) ON [PRIMARY]

GO
