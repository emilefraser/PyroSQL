SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductVendorSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductVendorSAT](
	[ProductVendorVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[AverageLeadTime] [int] NOT NULL,
	[MaxOrderQty] [int] NOT NULL,
	[MinOrderQty] [int] NOT NULL,
	[OnOrderQty] [int] NOT NULL,
	[StandardPrice] [money] NOT NULL,
	[UnitMeasureCode] [char](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LastReceiptCost] [money] NULL,
	[LastReceiptDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductVendorVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductVe__Produ__2D3D91F9]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductVendorSAT]'))
ALTER TABLE [datavault].[ProductVendorSAT]  WITH CHECK ADD FOREIGN KEY([ProductVendorVID])
REFERENCES [datavault].[ProductVendorLINK] ([ProductVendorVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductVe__Produ__3667D4D7]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductVendorSAT]'))
ALTER TABLE [datavault].[ProductVendorSAT]  WITH CHECK ADD FOREIGN KEY([ProductVendorVID])
REFERENCES [datavault].[ProductVendorLINK] ([ProductVendorVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductVe__Produ__38CF4036]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductVendorSAT]'))
ALTER TABLE [datavault].[ProductVendorSAT]  WITH CHECK ADD FOREIGN KEY([ProductVendorVID])
REFERENCES [datavault].[ProductVendorLINK] ([ProductVendorVID])
GO
