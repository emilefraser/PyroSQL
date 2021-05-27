SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[PurchaseOrderWasPlacedWithVendorLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[PurchaseOrderWasPlacedWithVendorLINK](
	[PurchaseOrderWasPlacedWithVendorVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[PurchaseOrderVID] [bigint] NOT NULL,
	[VendorVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PurchaseOrderWasPlacedWithVendorVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PurchaseOrderVID] ASC,
	[VendorVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PurchaseOrderVID] ASC,
	[VendorVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PurchaseOrderVID] ASC,
	[VendorVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Purch__35D2D7FA]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderWasPlacedWithVendorLINK]'))
ALTER TABLE [datavault].[PurchaseOrderWasPlacedWithVendorLINK]  WITH CHECK ADD FOREIGN KEY([PurchaseOrderVID])
REFERENCES [datavault].[PurchaseOrderHUB] ([PurchaseOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Purch__3EFD1AD8]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderWasPlacedWithVendorLINK]'))
ALTER TABLE [datavault].[PurchaseOrderWasPlacedWithVendorLINK]  WITH CHECK ADD FOREIGN KEY([PurchaseOrderVID])
REFERENCES [datavault].[PurchaseOrderHUB] ([PurchaseOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Purch__41648637]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderWasPlacedWithVendorLINK]'))
ALTER TABLE [datavault].[PurchaseOrderWasPlacedWithVendorLINK]  WITH CHECK ADD FOREIGN KEY([PurchaseOrderVID])
REFERENCES [datavault].[PurchaseOrderHUB] ([PurchaseOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Vendo__36C6FC33]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderWasPlacedWithVendorLINK]'))
ALTER TABLE [datavault].[PurchaseOrderWasPlacedWithVendorLINK]  WITH CHECK ADD FOREIGN KEY([VendorVID])
REFERENCES [datavault].[VendorHUB] ([VendorVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Vendo__3FF13F11]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderWasPlacedWithVendorLINK]'))
ALTER TABLE [datavault].[PurchaseOrderWasPlacedWithVendorLINK]  WITH CHECK ADD FOREIGN KEY([VendorVID])
REFERENCES [datavault].[VendorHUB] ([VendorVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Vendo__4258AA70]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderWasPlacedWithVendorLINK]'))
ALTER TABLE [datavault].[PurchaseOrderWasPlacedWithVendorLINK]  WITH CHECK ADD FOREIGN KEY([VendorVID])
REFERENCES [datavault].[VendorHUB] ([VendorVID])
GO
