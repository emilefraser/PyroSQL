SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductProductPhotoLINK](
	[ProductProductPhotoVID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProductVID] [bigint] NOT NULL,
	[ProductPhotoVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
