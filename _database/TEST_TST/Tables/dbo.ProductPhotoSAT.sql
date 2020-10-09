SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductPhotoSAT](
	[ProductPhotoVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[LargePhoto] [varbinary](1) NULL,
	[LargePhotoFileName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ThumbNailPhoto] [varbinary](1) NULL,
	[ThumbnailPhotoFileName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
