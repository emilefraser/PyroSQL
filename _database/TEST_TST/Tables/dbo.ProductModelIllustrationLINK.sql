SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductModelIllustrationLINK](
	[ProductModelIllustrationVID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProductModelVID] [bigint] NOT NULL,
	[IllustrationVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
