SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductModelSAT](
	[ProductModelVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CatalogDescription] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Instructions] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
