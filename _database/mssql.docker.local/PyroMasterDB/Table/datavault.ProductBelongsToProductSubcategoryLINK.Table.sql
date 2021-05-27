SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductBelongsToProductSubcategoryLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductBelongsToProductSubcategoryLINK](
	[ProductBelongsToProductSubcategoryVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[ProductVID] [bigint] NOT NULL,
	[ProductSubcategoryVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductBelongsToProductSubcategoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductVID] ASC,
	[ProductSubcategoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductVID] ASC,
	[ProductSubcategoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductVID] ASC,
	[ProductSubcategoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductBe__Produ__09003183]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductBelongsToProductSubcategoryLINK]'))
ALTER TABLE [datavault].[ProductBelongsToProductSubcategoryLINK]  WITH CHECK ADD FOREIGN KEY([ProductSubcategoryVID])
REFERENCES [datavault].[ProductSubcategoryHUB] ([ProductSubcategoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductBe__Produ__09F455BC]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductBelongsToProductSubcategoryLINK]'))
ALTER TABLE [datavault].[ProductBelongsToProductSubcategoryLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductBe__Produ__122A7461]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductBelongsToProductSubcategoryLINK]'))
ALTER TABLE [datavault].[ProductBelongsToProductSubcategoryLINK]  WITH CHECK ADD FOREIGN KEY([ProductSubcategoryVID])
REFERENCES [datavault].[ProductSubcategoryHUB] ([ProductSubcategoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductBe__Produ__131E989A]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductBelongsToProductSubcategoryLINK]'))
ALTER TABLE [datavault].[ProductBelongsToProductSubcategoryLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductBe__Produ__1491DFC0]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductBelongsToProductSubcategoryLINK]'))
ALTER TABLE [datavault].[ProductBelongsToProductSubcategoryLINK]  WITH CHECK ADD FOREIGN KEY([ProductSubcategoryVID])
REFERENCES [datavault].[ProductSubcategoryHUB] ([ProductSubcategoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductBe__Produ__158603F9]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductBelongsToProductSubcategoryLINK]'))
ALTER TABLE [datavault].[ProductBelongsToProductSubcategoryLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
