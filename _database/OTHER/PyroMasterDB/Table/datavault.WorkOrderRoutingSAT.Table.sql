SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[WorkOrderRoutingSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[WorkOrderRoutingSAT](
	[WorkOrderRoutingVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[PlannedCost] [money] NOT NULL,
	[ScheduledEndDate] [datetime] NOT NULL,
	[ScheduledStartDate] [datetime] NOT NULL,
	[ActualCost] [money] NULL,
	[ActualEndDate] [datetime] NULL,
	[ActualResourceHours] [decimal](18, 0) NULL,
	[ActualStartDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[WorkOrderRoutingVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__WorkOrder__WorkO__70F39DC8]') AND parent_object_id = OBJECT_ID(N'[datavault].[WorkOrderRoutingSAT]'))
ALTER TABLE [datavault].[WorkOrderRoutingSAT]  WITH CHECK ADD FOREIGN KEY([WorkOrderRoutingVID])
REFERENCES [datavault].[WorkOrderRoutingHUB] ([WorkOrderRoutingVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__WorkOrder__WorkO__7A1DE0A6]') AND parent_object_id = OBJECT_ID(N'[datavault].[WorkOrderRoutingSAT]'))
ALTER TABLE [datavault].[WorkOrderRoutingSAT]  WITH CHECK ADD FOREIGN KEY([WorkOrderRoutingVID])
REFERENCES [datavault].[WorkOrderRoutingHUB] ([WorkOrderRoutingVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__WorkOrder__WorkO__7C854C05]') AND parent_object_id = OBJECT_ID(N'[datavault].[WorkOrderRoutingSAT]'))
ALTER TABLE [datavault].[WorkOrderRoutingSAT]  WITH CHECK ADD FOREIGN KEY([WorkOrderRoutingVID])
REFERENCES [datavault].[WorkOrderRoutingHUB] ([WorkOrderRoutingVID])
GO
