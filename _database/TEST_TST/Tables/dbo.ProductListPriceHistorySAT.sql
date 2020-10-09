SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductListPriceHistorySAT](
	[ProductListPriceHistoryVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[ListPrice] [money] NOT NULL,
	[EndDate] [datetime] NULL
) ON [PRIMARY]

GO
