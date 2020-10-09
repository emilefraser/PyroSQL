SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PurchaseOrderWasPlacedWithVendorLINK](
	[PurchaseOrderWasPlacedWithVendorVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[PurchaseOrderVID] [bigint] NOT NULL,
	[VendorVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
