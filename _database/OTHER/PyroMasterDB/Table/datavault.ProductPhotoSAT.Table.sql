SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductPhotoSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductPhotoSAT](
	[ProductPhotoVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[LargePhoto] [varbinary](1) NULL,
	[LargePhotoFileName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ThumbNailPhoto] [varbinary](1) NULL,
	[ThumbnailPhotoFileName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductPhotoVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductPh__Produ__1EEF72A2]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductPhotoSAT]'))
ALTER TABLE [datavault].[ProductPhotoSAT]  WITH CHECK ADD FOREIGN KEY([ProductPhotoVID])
REFERENCES [datavault].[ProductPhotoHUB] ([ProductPhotoVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductPh__Produ__2819B580]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductPhotoSAT]'))
ALTER TABLE [datavault].[ProductPhotoSAT]  WITH CHECK ADD FOREIGN KEY([ProductPhotoVID])
REFERENCES [datavault].[ProductPhotoHUB] ([ProductPhotoVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductPh__Produ__2A8120DF]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductPhotoSAT]'))
ALTER TABLE [datavault].[ProductPhotoSAT]  WITH CHECK ADD FOREIGN KEY([ProductPhotoVID])
REFERENCES [datavault].[ProductPhotoHUB] ([ProductPhotoVID])
GO
