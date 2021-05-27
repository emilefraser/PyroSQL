SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductModelProductDescriptionCultureLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductModelProductDescriptionCultureLINK](
	[ProductModelProductDescriptionCultureVID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProductModelVID] [bigint] NOT NULL,
	[ProductDescriptionVID] [bigint] NOT NULL,
	[CultureID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductModelProductDescriptionCultureVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductModelVID] ASC,
	[ProductDescriptionVID] ASC,
	[CultureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductModelVID] ASC,
	[ProductDescriptionVID] ASC,
	[CultureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductModelVID] ASC,
	[ProductDescriptionVID] ASC,
	[CultureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductMo__Produ__1C1305F7]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductModelProductDescriptionCultureLINK]'))
ALTER TABLE [datavault].[ProductModelProductDescriptionCultureLINK]  WITH CHECK ADD FOREIGN KEY([ProductDescriptionVID])
REFERENCES [datavault].[ProductDescriptionHUB] ([ProductDescriptionVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductMo__Produ__1D072A30]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductModelProductDescriptionCultureLINK]'))
ALTER TABLE [datavault].[ProductModelProductDescriptionCultureLINK]  WITH CHECK ADD FOREIGN KEY([ProductModelVID])
REFERENCES [datavault].[ProductModelHUB] ([ProductModelVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductMo__Produ__253D48D5]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductModelProductDescriptionCultureLINK]'))
ALTER TABLE [datavault].[ProductModelProductDescriptionCultureLINK]  WITH CHECK ADD FOREIGN KEY([ProductDescriptionVID])
REFERENCES [datavault].[ProductDescriptionHUB] ([ProductDescriptionVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductMo__Produ__26316D0E]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductModelProductDescriptionCultureLINK]'))
ALTER TABLE [datavault].[ProductModelProductDescriptionCultureLINK]  WITH CHECK ADD FOREIGN KEY([ProductModelVID])
REFERENCES [datavault].[ProductModelHUB] ([ProductModelVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductMo__Produ__27A4B434]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductModelProductDescriptionCultureLINK]'))
ALTER TABLE [datavault].[ProductModelProductDescriptionCultureLINK]  WITH CHECK ADD FOREIGN KEY([ProductDescriptionVID])
REFERENCES [datavault].[ProductDescriptionHUB] ([ProductDescriptionVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductMo__Produ__2898D86D]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductModelProductDescriptionCultureLINK]'))
ALTER TABLE [datavault].[ProductModelProductDescriptionCultureLINK]  WITH CHECK ADD FOREIGN KEY([ProductModelVID])
REFERENCES [datavault].[ProductModelHUB] ([ProductModelVID])
GO
