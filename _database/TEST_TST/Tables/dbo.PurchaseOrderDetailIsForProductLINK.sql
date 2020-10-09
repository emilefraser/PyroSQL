SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PurchaseOrderDetailIsForProductLINK](
	[PurchaseOrderDetailIsForProductVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[ProductVID] [bigint] NOT NULL,
	[PurchaseOrderDetailVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
