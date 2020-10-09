SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SpecialOfferProductLINK](
	[SpecialOfferProductVID] [bigint] IDENTITY(1,1) NOT NULL,
	[SpecialOfferVID] [bigint] NOT NULL,
	[ProductVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
