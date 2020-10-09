SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PurchaseOrderDetailHUB](
	[PurchaseOrderDetailVID] [bigint] IDENTITY(1,1) NOT NULL,
	[PurchaseOrderID] [bigint] NOT NULL,
	[PurchaseOrderDetailID] [bigint] NOT NULL
) ON [PRIMARY]

GO
