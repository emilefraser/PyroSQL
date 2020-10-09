SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[LinksToImages](
	[ItemID] [int] NOT NULL,
	[Item] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LinkedToImage] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
