SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PurchaseOrderDetailSAT](
	[PurchaseOrderDetailVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[DueDate] [datetime] NOT NULL,
	[OrderQty] [int] NOT NULL,
	[ReceivedQty] [decimal](18, 0) NOT NULL,
	[RejectedQty] [decimal](18, 0) NOT NULL,
	[UnitPrice] [money] NOT NULL
) ON [PRIMARY]

GO
