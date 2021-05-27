SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SalesOrderIsAssignedToSalesTerritoryLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SalesOrderIsAssignedToSalesTerritoryLINK](
	[SalesOrderIsAssignedToSalesTerritoryVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[SalesOrderVID] [bigint] NOT NULL,
	[SalesTerritoryVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesOrderIsAssignedToSalesTerritoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderVID] ASC,
	[SalesTerritoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderVID] ASC,
	[SalesTerritoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderVID] ASC,
	[SalesTerritoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__46093FC3]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderIsAssignedToSalesTerritoryLINK]'))
ALTER TABLE [datavault].[SalesOrderIsAssignedToSalesTerritoryLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__46FD63FC]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderIsAssignedToSalesTerritoryLINK]'))
ALTER TABLE [datavault].[SalesOrderIsAssignedToSalesTerritoryLINK]  WITH CHECK ADD FOREIGN KEY([SalesTerritoryVID])
REFERENCES [datavault].[SalesTerritoryHUB] ([SalesTerritoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__4F3382A1]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderIsAssignedToSalesTerritoryLINK]'))
ALTER TABLE [datavault].[SalesOrderIsAssignedToSalesTerritoryLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__5027A6DA]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderIsAssignedToSalesTerritoryLINK]'))
ALTER TABLE [datavault].[SalesOrderIsAssignedToSalesTerritoryLINK]  WITH CHECK ADD FOREIGN KEY([SalesTerritoryVID])
REFERENCES [datavault].[SalesTerritoryHUB] ([SalesTerritoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__519AEE00]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderIsAssignedToSalesTerritoryLINK]'))
ALTER TABLE [datavault].[SalesOrderIsAssignedToSalesTerritoryLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__528F1239]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderIsAssignedToSalesTerritoryLINK]'))
ALTER TABLE [datavault].[SalesOrderIsAssignedToSalesTerritoryLINK]  WITH CHECK ADD FOREIGN KEY([SalesTerritoryVID])
REFERENCES [datavault].[SalesTerritoryHUB] ([SalesTerritoryVID])
GO
