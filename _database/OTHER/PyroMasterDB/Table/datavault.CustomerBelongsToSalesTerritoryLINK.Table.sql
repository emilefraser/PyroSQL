SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[CustomerBelongsToSalesTerritoryLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[CustomerBelongsToSalesTerritoryLINK](
	[CustomerBelongsToSalesTerritoryVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[CustomerVID] [bigint] NOT NULL,
	[SalesTerritoryVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CustomerBelongsToSalesTerritoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CustomerVID] ASC,
	[SalesTerritoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CustomerVID] ASC,
	[SalesTerritoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CustomerVID] ASC,
	[SalesTerritoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CustomerB__Custo__61E66462]') AND parent_object_id = OBJECT_ID(N'[datavault].[CustomerBelongsToSalesTerritoryLINK]'))
ALTER TABLE [datavault].[CustomerBelongsToSalesTerritoryLINK]  WITH CHECK ADD FOREIGN KEY([CustomerVID])
REFERENCES [datavault].[CustomerHUB] ([CustomerVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CustomerB__Custo__6B10A740]') AND parent_object_id = OBJECT_ID(N'[datavault].[CustomerBelongsToSalesTerritoryLINK]'))
ALTER TABLE [datavault].[CustomerBelongsToSalesTerritoryLINK]  WITH CHECK ADD FOREIGN KEY([CustomerVID])
REFERENCES [datavault].[CustomerHUB] ([CustomerVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CustomerB__Custo__6D78129F]') AND parent_object_id = OBJECT_ID(N'[datavault].[CustomerBelongsToSalesTerritoryLINK]'))
ALTER TABLE [datavault].[CustomerBelongsToSalesTerritoryLINK]  WITH CHECK ADD FOREIGN KEY([CustomerVID])
REFERENCES [datavault].[CustomerHUB] ([CustomerVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CustomerB__Sales__62DA889B]') AND parent_object_id = OBJECT_ID(N'[datavault].[CustomerBelongsToSalesTerritoryLINK]'))
ALTER TABLE [datavault].[CustomerBelongsToSalesTerritoryLINK]  WITH CHECK ADD FOREIGN KEY([SalesTerritoryVID])
REFERENCES [datavault].[SalesTerritoryHUB] ([SalesTerritoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CustomerB__Sales__6C04CB79]') AND parent_object_id = OBJECT_ID(N'[datavault].[CustomerBelongsToSalesTerritoryLINK]'))
ALTER TABLE [datavault].[CustomerBelongsToSalesTerritoryLINK]  WITH CHECK ADD FOREIGN KEY([SalesTerritoryVID])
REFERENCES [datavault].[SalesTerritoryHUB] ([SalesTerritoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CustomerB__Sales__6E6C36D8]') AND parent_object_id = OBJECT_ID(N'[datavault].[CustomerBelongsToSalesTerritoryLINK]'))
ALTER TABLE [datavault].[CustomerBelongsToSalesTerritoryLINK]  WITH CHECK ADD FOREIGN KEY([SalesTerritoryVID])
REFERENCES [datavault].[SalesTerritoryHUB] ([SalesTerritoryVID])
GO
