SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[PurchaseOrderDetailBelongsToPurchaseOrderLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[PurchaseOrderDetailBelongsToPurchaseOrderLINK](
	[PurchaseOrderDetailBelongsToPurchaseOrde] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[PurchaseOrderDetailVID] [bigint] NOT NULL,
	[PurchaseOrderVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PurchaseOrderDetailBelongsToPurchaseOrde] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PurchaseOrderDetailVID] ASC,
	[PurchaseOrderVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PurchaseOrderDetailVID] ASC,
	[PurchaseOrderVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PurchaseOrderDetailVID] ASC,
	[PurchaseOrderVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Purch__2E31B632]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderDetailBelongsToPurchaseOrderLINK]'))
ALTER TABLE [datavault].[PurchaseOrderDetailBelongsToPurchaseOrderLINK]  WITH CHECK ADD FOREIGN KEY([PurchaseOrderDetailVID])
REFERENCES [datavault].[PurchaseOrderDetailHUB] ([PurchaseOrderDetailVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Purch__2F25DA6B]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderDetailBelongsToPurchaseOrderLINK]'))
ALTER TABLE [datavault].[PurchaseOrderDetailBelongsToPurchaseOrderLINK]  WITH CHECK ADD FOREIGN KEY([PurchaseOrderVID])
REFERENCES [datavault].[PurchaseOrderHUB] ([PurchaseOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Purch__375BF910]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderDetailBelongsToPurchaseOrderLINK]'))
ALTER TABLE [datavault].[PurchaseOrderDetailBelongsToPurchaseOrderLINK]  WITH CHECK ADD FOREIGN KEY([PurchaseOrderDetailVID])
REFERENCES [datavault].[PurchaseOrderDetailHUB] ([PurchaseOrderDetailVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Purch__38501D49]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderDetailBelongsToPurchaseOrderLINK]'))
ALTER TABLE [datavault].[PurchaseOrderDetailBelongsToPurchaseOrderLINK]  WITH CHECK ADD FOREIGN KEY([PurchaseOrderVID])
REFERENCES [datavault].[PurchaseOrderHUB] ([PurchaseOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Purch__39C3646F]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderDetailBelongsToPurchaseOrderLINK]'))
ALTER TABLE [datavault].[PurchaseOrderDetailBelongsToPurchaseOrderLINK]  WITH CHECK ADD FOREIGN KEY([PurchaseOrderDetailVID])
REFERENCES [datavault].[PurchaseOrderDetailHUB] ([PurchaseOrderDetailVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Purch__3AB788A8]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderDetailBelongsToPurchaseOrderLINK]'))
ALTER TABLE [datavault].[PurchaseOrderDetailBelongsToPurchaseOrderLINK]  WITH CHECK ADD FOREIGN KEY([PurchaseOrderVID])
REFERENCES [datavault].[PurchaseOrderHUB] ([PurchaseOrderVID])
GO
