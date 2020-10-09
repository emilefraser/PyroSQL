SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SalesTerritorySAT](
	[SalesTerritoryVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[CostLastYear] [money] NOT NULL,
	[CostYTD] [money] NOT NULL,
	[GroupSalesTerritoryGroupName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalesLastYear] [money] NOT NULL,
	[SalesYTD] [money] NOT NULL
) ON [PRIMARY]

GO
