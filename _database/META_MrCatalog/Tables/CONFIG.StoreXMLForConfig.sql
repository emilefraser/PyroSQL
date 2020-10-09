SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [CONFIG].[StoreXMLForConfig](
	[ConfigID] [int] IDENTITY(1,1) NOT NULL,
	[ConfigDescription] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ConfigXMLDataEntity] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ConfigXMLField] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
