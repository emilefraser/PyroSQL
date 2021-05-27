SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductProductPhotoSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductProductPhotoSAT](
	[ProductProductPhotoVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Primary] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductProductPhotoVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductPr__Produ__21CBDF4D]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductProductPhotoSAT]'))
ALTER TABLE [datavault].[ProductProductPhotoSAT]  WITH CHECK ADD FOREIGN KEY([ProductProductPhotoVID])
REFERENCES [datavault].[ProductProductPhotoLINK] ([ProductProductPhotoVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductPr__Produ__2AF6222B]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductProductPhotoSAT]'))
ALTER TABLE [datavault].[ProductProductPhotoSAT]  WITH CHECK ADD FOREIGN KEY([ProductProductPhotoVID])
REFERENCES [datavault].[ProductProductPhotoLINK] ([ProductProductPhotoVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductPr__Produ__2D5D8D8A]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductProductPhotoSAT]'))
ALTER TABLE [datavault].[ProductProductPhotoSAT]  WITH CHECK ADD FOREIGN KEY([ProductProductPhotoVID])
REFERENCES [datavault].[ProductProductPhotoLINK] ([ProductProductPhotoVID])
GO
