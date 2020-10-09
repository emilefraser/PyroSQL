SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[WorkOrderRoutingHUB](
	[WorkOrderRoutingVID] [bigint] IDENTITY(1,1) NOT NULL,
	[WorkOrderID] [bigint] NOT NULL,
	[ProductID] [bigint] NOT NULL,
	[OperationSequence] [smallint] NOT NULL,
	[LocationVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
