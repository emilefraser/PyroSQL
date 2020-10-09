SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CustomerBelongsToSalesTerritoryLINK](
	[CustomerBelongsToSalesTerritoryVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[CustomerVID] [bigint] NOT NULL,
	[SalesTerritoryVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
