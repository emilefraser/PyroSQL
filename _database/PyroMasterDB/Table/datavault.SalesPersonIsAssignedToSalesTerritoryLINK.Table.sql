SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SalesPersonIsAssignedToSalesTerritoryLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SalesPersonIsAssignedToSalesTerritoryLINK](
	[SalesPersonIsAssignedToSalesTerritoryVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[SalesPersonVID] [bigint] NOT NULL,
	[SalesTerritoryVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesPersonIsAssignedToSalesTerritoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesPersonVID] ASC,
	[SalesTerritoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesPersonVID] ASC,
	[SalesTerritoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesPersonVID] ASC,
	[SalesTerritoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Sales__5086CE36]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonIsAssignedToSalesTerritoryLINK]'))
ALTER TABLE [datavault].[SalesPersonIsAssignedToSalesTerritoryLINK]  WITH CHECK ADD FOREIGN KEY([SalesPersonVID])
REFERENCES [datavault].[SalesPersonHUB] ([SalesPersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Sales__517AF26F]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonIsAssignedToSalesTerritoryLINK]'))
ALTER TABLE [datavault].[SalesPersonIsAssignedToSalesTerritoryLINK]  WITH CHECK ADD FOREIGN KEY([SalesTerritoryVID])
REFERENCES [datavault].[SalesTerritoryHUB] ([SalesTerritoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Sales__59B11114]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonIsAssignedToSalesTerritoryLINK]'))
ALTER TABLE [datavault].[SalesPersonIsAssignedToSalesTerritoryLINK]  WITH CHECK ADD FOREIGN KEY([SalesPersonVID])
REFERENCES [datavault].[SalesPersonHUB] ([SalesPersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Sales__5AA5354D]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonIsAssignedToSalesTerritoryLINK]'))
ALTER TABLE [datavault].[SalesPersonIsAssignedToSalesTerritoryLINK]  WITH CHECK ADD FOREIGN KEY([SalesTerritoryVID])
REFERENCES [datavault].[SalesTerritoryHUB] ([SalesTerritoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Sales__5C187C73]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonIsAssignedToSalesTerritoryLINK]'))
ALTER TABLE [datavault].[SalesPersonIsAssignedToSalesTerritoryLINK]  WITH CHECK ADD FOREIGN KEY([SalesPersonVID])
REFERENCES [datavault].[SalesPersonHUB] ([SalesPersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Sales__5D0CA0AC]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonIsAssignedToSalesTerritoryLINK]'))
ALTER TABLE [datavault].[SalesPersonIsAssignedToSalesTerritoryLINK]  WITH CHECK ADD FOREIGN KEY([SalesTerritoryVID])
REFERENCES [datavault].[SalesTerritoryHUB] ([SalesTerritoryVID])
GO
