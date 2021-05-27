SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[PurchaseOrderDetailSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[PurchaseOrderDetailSAT](
	[PurchaseOrderDetailVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[DueDate] [datetime] NOT NULL,
	[OrderQty] [int] NOT NULL,
	[ReceivedQty] [decimal](18, 0) NOT NULL,
	[RejectedQty] [decimal](18, 0) NOT NULL,
	[UnitPrice] [money] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PurchaseOrderDetailVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Purch__32024716]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderDetailSAT]'))
ALTER TABLE [datavault].[PurchaseOrderDetailSAT]  WITH CHECK ADD FOREIGN KEY([PurchaseOrderDetailVID])
REFERENCES [datavault].[PurchaseOrderDetailHUB] ([PurchaseOrderDetailVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Purch__3B2C89F4]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderDetailSAT]'))
ALTER TABLE [datavault].[PurchaseOrderDetailSAT]  WITH CHECK ADD FOREIGN KEY([PurchaseOrderDetailVID])
REFERENCES [datavault].[PurchaseOrderDetailHUB] ([PurchaseOrderDetailVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Purch__3D93F553]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderDetailSAT]'))
ALTER TABLE [datavault].[PurchaseOrderDetailSAT]  WITH CHECK ADD FOREIGN KEY([PurchaseOrderDetailVID])
REFERENCES [datavault].[PurchaseOrderDetailHUB] ([PurchaseOrderDetailVID])
GO
