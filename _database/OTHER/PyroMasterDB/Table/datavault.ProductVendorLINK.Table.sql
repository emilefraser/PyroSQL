SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductVendorLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductVendorLINK](
	[ProductVendorVID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProductVID] [bigint] NOT NULL,
	[VendorVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductVendorVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductVID] ASC,
	[VendorVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductVID] ASC,
	[VendorVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductVID] ASC,
	[VendorVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductVe__Produ__2B554987]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductVendorLINK]'))
ALTER TABLE [datavault].[ProductVendorLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductVe__Produ__347F8C65]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductVendorLINK]'))
ALTER TABLE [datavault].[ProductVendorLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductVe__Produ__36E6F7C4]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductVendorLINK]'))
ALTER TABLE [datavault].[ProductVendorLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductVe__Vendo__2C496DC0]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductVendorLINK]'))
ALTER TABLE [datavault].[ProductVendorLINK]  WITH CHECK ADD FOREIGN KEY([VendorVID])
REFERENCES [datavault].[VendorHUB] ([VendorVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductVe__Vendo__3573B09E]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductVendorLINK]'))
ALTER TABLE [datavault].[ProductVendorLINK]  WITH CHECK ADD FOREIGN KEY([VendorVID])
REFERENCES [datavault].[VendorHUB] ([VendorVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductVe__Vendo__37DB1BFD]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductVendorLINK]'))
ALTER TABLE [datavault].[ProductVendorLINK]  WITH CHECK ADD FOREIGN KEY([VendorVID])
REFERENCES [datavault].[VendorHUB] ([VendorVID])
GO
