SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SalesOrderIsAssignedToSalesTerritoryLINK](
	[SalesOrderIsAssignedToSalesTerritoryVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[SalesOrderVID] [bigint] NOT NULL,
	[SalesTerritoryVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
