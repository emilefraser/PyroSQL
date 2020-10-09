SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[WorkOrderSAT](
	[WorkOrderVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[DueDate] [datetime] NOT NULL,
	[OrderQty] [int] NOT NULL,
	[ScrappedQty] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[ScrapReasonID] [bigint] NULL
) ON [PRIMARY]

GO
