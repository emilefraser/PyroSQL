SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CatalogItemExtendedContent](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[ItemId] [uniqueidentifier] NULL,
	[ContentType] [varchar](50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Content] [varbinary](max) NULL,
	[ModifiedDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
