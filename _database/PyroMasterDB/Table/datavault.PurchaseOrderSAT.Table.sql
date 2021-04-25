SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[PurchaseOrderSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[PurchaseOrderSAT](
	[PurchaseOrderVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Freight] [money] NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[PurchaseOrderNumber] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[RevisionNumber] [tinyint] NOT NULL,
	[ShipMethodID] [bigint] NOT NULL,
	[StatusPurchaseOrderStatusCode] [tinyint] NOT NULL,
	[SubTotal] [money] NOT NULL,
	[TaxAmt] [money] NOT NULL,
	[ShipDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[PurchaseOrderVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Purch__32F66B4F]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderSAT]'))
ALTER TABLE [datavault].[PurchaseOrderSAT]  WITH CHECK ADD FOREIGN KEY([PurchaseOrderVID])
REFERENCES [datavault].[PurchaseOrderHUB] ([PurchaseOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Purch__3C20AE2D]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderSAT]'))
ALTER TABLE [datavault].[PurchaseOrderSAT]  WITH CHECK ADD FOREIGN KEY([PurchaseOrderVID])
REFERENCES [datavault].[PurchaseOrderHUB] ([PurchaseOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Purch__3E88198C]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderSAT]'))
ALTER TABLE [datavault].[PurchaseOrderSAT]  WITH CHECK ADD FOREIGN KEY([PurchaseOrderVID])
REFERENCES [datavault].[PurchaseOrderHUB] ([PurchaseOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__PurchaseO__Statu__0035E158]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderSAT]'))
ALTER TABLE [datavault].[PurchaseOrderSAT]  WITH CHECK ADD CHECK  (([StatusPurchaseOrderStatusCode]>=(1) AND [StatusPurchaseOrderStatusCode]<=(8)))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__PurchaseO__Statu__058F9352]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderSAT]'))
ALTER TABLE [datavault].[PurchaseOrderSAT]  WITH CHECK ADD CHECK  (([StatusPurchaseOrderStatusCode]>=(1) AND [StatusPurchaseOrderStatusCode]<=(8)))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__PurchaseO__Statu__07F6FEB1]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderSAT]'))
ALTER TABLE [datavault].[PurchaseOrderSAT]  WITH CHECK ADD CHECK  (([StatusPurchaseOrderStatusCode]>=(1) AND [StatusPurchaseOrderStatusCode]<=(8)))
GO
