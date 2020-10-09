SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Images](
	[ID] [int] NOT NULL,
	[ImageName] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ImageBlob] [varbinary](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
