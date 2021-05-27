SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductSubcategoryBelongsToProductCategoryLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductSubcategoryBelongsToProductCategoryLINK](
	[ProductSubcategoryBelongsToProductCatego] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[ProductCategoryVID] [bigint] NOT NULL,
	[ProductSubcategoryVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductSubcategoryBelongsToProductCatego] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductSubcategoryVID] ASC,
	[ProductCategoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductSubcategoryVID] ASC,
	[ProductCategoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductSubcategoryVID] ASC,
	[ProductCategoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductSu__Produ__2784B8A3]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductSubcategoryBelongsToProductCategoryLINK]'))
ALTER TABLE [datavault].[ProductSubcategoryBelongsToProductCategoryLINK]  WITH CHECK ADD FOREIGN KEY([ProductCategoryVID])
REFERENCES [datavault].[ProductCategoryHUB] ([ProductCategoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductSu__Produ__2878DCDC]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductSubcategoryBelongsToProductCategoryLINK]'))
ALTER TABLE [datavault].[ProductSubcategoryBelongsToProductCategoryLINK]  WITH CHECK ADD FOREIGN KEY([ProductSubcategoryVID])
REFERENCES [datavault].[ProductSubcategoryHUB] ([ProductSubcategoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductSu__Produ__30AEFB81]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductSubcategoryBelongsToProductCategoryLINK]'))
ALTER TABLE [datavault].[ProductSubcategoryBelongsToProductCategoryLINK]  WITH CHECK ADD FOREIGN KEY([ProductCategoryVID])
REFERENCES [datavault].[ProductCategoryHUB] ([ProductCategoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductSu__Produ__31A31FBA]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductSubcategoryBelongsToProductCategoryLINK]'))
ALTER TABLE [datavault].[ProductSubcategoryBelongsToProductCategoryLINK]  WITH CHECK ADD FOREIGN KEY([ProductSubcategoryVID])
REFERENCES [datavault].[ProductSubcategoryHUB] ([ProductSubcategoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductSu__Produ__331666E0]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductSubcategoryBelongsToProductCategoryLINK]'))
ALTER TABLE [datavault].[ProductSubcategoryBelongsToProductCategoryLINK]  WITH CHECK ADD FOREIGN KEY([ProductCategoryVID])
REFERENCES [datavault].[ProductCategoryHUB] ([ProductCategoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductSu__Produ__340A8B19]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductSubcategoryBelongsToProductCategoryLINK]'))
ALTER TABLE [datavault].[ProductSubcategoryBelongsToProductCategoryLINK]  WITH CHECK ADD FOREIGN KEY([ProductSubcategoryVID])
REFERENCES [datavault].[ProductSubcategoryHUB] ([ProductSubcategoryVID])
GO
