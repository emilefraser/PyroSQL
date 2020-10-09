SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductListPriceHistoryInvolvesProductLINK](
	[ProductListPriceHistoryInvolvesProductVI] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[ProductListPriceHistoryVID] [bigint] NOT NULL,
	[ProductVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
