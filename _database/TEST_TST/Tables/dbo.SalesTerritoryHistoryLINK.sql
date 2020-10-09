SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SalesTerritoryHistoryLINK](
	[SalesTerritoryHistoryVID] [bigint] IDENTITY(1,1) NOT NULL,
	[SalesPersonVID] [bigint] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[SalesTerritoryVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
