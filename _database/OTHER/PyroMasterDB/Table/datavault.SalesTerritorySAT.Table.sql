SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SalesTerritorySAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SalesTerritorySAT](
	[SalesTerritoryVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[CostLastYear] [money] NOT NULL,
	[CostYTD] [money] NOT NULL,
	[GroupSalesTerritoryGroupName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalesLastYear] [money] NOT NULL,
	[SalesYTD] [money] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesTerritoryVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesTerr__Sales__591C1437]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesTerritorySAT]'))
ALTER TABLE [datavault].[SalesTerritorySAT]  WITH CHECK ADD FOREIGN KEY([SalesTerritoryVID])
REFERENCES [datavault].[SalesTerritoryHUB] ([SalesTerritoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesTerr__Sales__62465715]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesTerritorySAT]'))
ALTER TABLE [datavault].[SalesTerritorySAT]  WITH CHECK ADD FOREIGN KEY([SalesTerritoryVID])
REFERENCES [datavault].[SalesTerritoryHUB] ([SalesTerritoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesTerr__Sales__64ADC274]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesTerritorySAT]'))
ALTER TABLE [datavault].[SalesTerritorySAT]  WITH CHECK ADD FOREIGN KEY([SalesTerritoryVID])
REFERENCES [datavault].[SalesTerritoryHUB] ([SalesTerritoryVID])
GO
