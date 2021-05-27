SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductProductPhotoLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductProductPhotoLINK](
	[ProductProductPhotoVID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProductVID] [bigint] NOT NULL,
	[ProductPhotoVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductProductPhotoVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductVID] ASC,
	[ProductPhotoVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductVID] ASC,
	[ProductPhotoVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductVID] ASC,
	[ProductPhotoVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductPr__Produ__1FE396DB]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductProductPhotoLINK]'))
ALTER TABLE [datavault].[ProductProductPhotoLINK]  WITH CHECK ADD FOREIGN KEY([ProductPhotoVID])
REFERENCES [datavault].[ProductPhotoHUB] ([ProductPhotoVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductPr__Produ__20D7BB14]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductProductPhotoLINK]'))
ALTER TABLE [datavault].[ProductProductPhotoLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductPr__Produ__290DD9B9]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductProductPhotoLINK]'))
ALTER TABLE [datavault].[ProductProductPhotoLINK]  WITH CHECK ADD FOREIGN KEY([ProductPhotoVID])
REFERENCES [datavault].[ProductPhotoHUB] ([ProductPhotoVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductPr__Produ__2A01FDF2]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductProductPhotoLINK]'))
ALTER TABLE [datavault].[ProductProductPhotoLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductPr__Produ__2B754518]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductProductPhotoLINK]'))
ALTER TABLE [datavault].[ProductProductPhotoLINK]  WITH CHECK ADD FOREIGN KEY([ProductPhotoVID])
REFERENCES [datavault].[ProductPhotoHUB] ([ProductPhotoVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductPr__Produ__2C696951]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductProductPhotoLINK]'))
ALTER TABLE [datavault].[ProductProductPhotoLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
