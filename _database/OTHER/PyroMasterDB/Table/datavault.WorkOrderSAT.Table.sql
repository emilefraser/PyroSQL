SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[WorkOrderSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[WorkOrderSAT](
	[WorkOrderVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[DueDate] [datetime] NOT NULL,
	[OrderQty] [int] NOT NULL,
	[ScrappedQty] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[ScrapReasonID] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[WorkOrderVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__WorkOrder__WorkO__71E7C201]') AND parent_object_id = OBJECT_ID(N'[datavault].[WorkOrderSAT]'))
ALTER TABLE [datavault].[WorkOrderSAT]  WITH CHECK ADD FOREIGN KEY([WorkOrderVID])
REFERENCES [datavault].[WorkOrderHUB] ([WorkOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__WorkOrder__WorkO__7B1204DF]') AND parent_object_id = OBJECT_ID(N'[datavault].[WorkOrderSAT]'))
ALTER TABLE [datavault].[WorkOrderSAT]  WITH CHECK ADD FOREIGN KEY([WorkOrderVID])
REFERENCES [datavault].[WorkOrderHUB] ([WorkOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__WorkOrder__WorkO__7D79703E]') AND parent_object_id = OBJECT_ID(N'[datavault].[WorkOrderSAT]'))
ALTER TABLE [datavault].[WorkOrderSAT]  WITH CHECK ADD FOREIGN KEY([WorkOrderVID])
REFERENCES [datavault].[WorkOrderHUB] ([WorkOrderVID])
GO
