SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PurchaseOrderDetailBelongsToPurchaseOrderLINK](
	[PurchaseOrderDetailBelongsToPurchaseOrde] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[PurchaseOrderDetailVID] [bigint] NOT NULL,
	[PurchaseOrderVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
