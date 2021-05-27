SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[PurchaseOrderDetailIsForProductLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[PurchaseOrderDetailIsForProductLINK](
	[PurchaseOrderDetailIsForProductVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[ProductVID] [bigint] NOT NULL,
	[PurchaseOrderDetailVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PurchaseOrderDetailIsForProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PurchaseOrderDetailVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PurchaseOrderDetailVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PurchaseOrderDetailVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Produ__3019FEA4]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderDetailIsForProductLINK]'))
ALTER TABLE [datavault].[PurchaseOrderDetailIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Produ__39444182]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderDetailIsForProductLINK]'))
ALTER TABLE [datavault].[PurchaseOrderDetailIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Produ__3BABACE1]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderDetailIsForProductLINK]'))
ALTER TABLE [datavault].[PurchaseOrderDetailIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Purch__310E22DD]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderDetailIsForProductLINK]'))
ALTER TABLE [datavault].[PurchaseOrderDetailIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([PurchaseOrderDetailVID])
REFERENCES [datavault].[PurchaseOrderDetailHUB] ([PurchaseOrderDetailVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Purch__3A3865BB]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderDetailIsForProductLINK]'))
ALTER TABLE [datavault].[PurchaseOrderDetailIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([PurchaseOrderDetailVID])
REFERENCES [datavault].[PurchaseOrderDetailHUB] ([PurchaseOrderDetailVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Purch__3C9FD11A]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderDetailIsForProductLINK]'))
ALTER TABLE [datavault].[PurchaseOrderDetailIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([PurchaseOrderDetailVID])
REFERENCES [datavault].[PurchaseOrderDetailHUB] ([PurchaseOrderDetailVID])
GO
