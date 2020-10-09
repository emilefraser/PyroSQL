SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductSalesSAT](
	[ProductVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[ListPrice] [money] NOT NULL,
	[SellStartDate] [datetime] NOT NULL,
	[DiscontinuedDate] [datetime] NULL,
	[SellEndDate] [datetime] NULL
) ON [PRIMARY]

GO
