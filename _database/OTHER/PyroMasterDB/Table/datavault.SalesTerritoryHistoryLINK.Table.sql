SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SalesTerritoryHistoryLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SalesTerritoryHistoryLINK](
	[SalesTerritoryHistoryVID] [bigint] IDENTITY(1,1) NOT NULL,
	[SalesPersonVID] [bigint] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[SalesTerritoryVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesTerritoryHistoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesPersonVID] ASC,
	[StartDate] ASC,
	[SalesTerritoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesPersonVID] ASC,
	[StartDate] ASC,
	[SalesTerritoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesPersonVID] ASC,
	[StartDate] ASC,
	[SalesTerritoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesTerr__Sales__563FA78C]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesTerritoryHistoryLINK]'))
ALTER TABLE [datavault].[SalesTerritoryHistoryLINK]  WITH CHECK ADD FOREIGN KEY([SalesPersonVID])
REFERENCES [datavault].[SalesPersonHUB] ([SalesPersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesTerr__Sales__5733CBC5]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesTerritoryHistoryLINK]'))
ALTER TABLE [datavault].[SalesTerritoryHistoryLINK]  WITH CHECK ADD FOREIGN KEY([SalesTerritoryVID])
REFERENCES [datavault].[SalesTerritoryHUB] ([SalesTerritoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesTerr__Sales__5F69EA6A]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesTerritoryHistoryLINK]'))
ALTER TABLE [datavault].[SalesTerritoryHistoryLINK]  WITH CHECK ADD FOREIGN KEY([SalesPersonVID])
REFERENCES [datavault].[SalesPersonHUB] ([SalesPersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesTerr__Sales__605E0EA3]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesTerritoryHistoryLINK]'))
ALTER TABLE [datavault].[SalesTerritoryHistoryLINK]  WITH CHECK ADD FOREIGN KEY([SalesTerritoryVID])
REFERENCES [datavault].[SalesTerritoryHUB] ([SalesTerritoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesTerr__Sales__61D155C9]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesTerritoryHistoryLINK]'))
ALTER TABLE [datavault].[SalesTerritoryHistoryLINK]  WITH CHECK ADD FOREIGN KEY([SalesPersonVID])
REFERENCES [datavault].[SalesPersonHUB] ([SalesPersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesTerr__Sales__62C57A02]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesTerritoryHistoryLINK]'))
ALTER TABLE [datavault].[SalesTerritoryHistoryLINK]  WITH CHECK ADD FOREIGN KEY([SalesTerritoryVID])
REFERENCES [datavault].[SalesTerritoryHUB] ([SalesTerritoryVID])
GO
