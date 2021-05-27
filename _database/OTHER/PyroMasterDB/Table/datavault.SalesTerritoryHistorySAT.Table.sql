SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SalesTerritoryHistorySAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SalesTerritoryHistorySAT](
	[SalesTerritoryHistoryVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesTerritoryHistoryVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesTerr__Sales__5827EFFE]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesTerritoryHistorySAT]'))
ALTER TABLE [datavault].[SalesTerritoryHistorySAT]  WITH CHECK ADD FOREIGN KEY([SalesTerritoryHistoryVID])
REFERENCES [datavault].[SalesTerritoryHistoryLINK] ([SalesTerritoryHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesTerr__Sales__615232DC]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesTerritoryHistorySAT]'))
ALTER TABLE [datavault].[SalesTerritoryHistorySAT]  WITH CHECK ADD FOREIGN KEY([SalesTerritoryHistoryVID])
REFERENCES [datavault].[SalesTerritoryHistoryLINK] ([SalesTerritoryHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesTerr__Sales__63B99E3B]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesTerritoryHistorySAT]'))
ALTER TABLE [datavault].[SalesTerritoryHistorySAT]  WITH CHECK ADD FOREIGN KEY([SalesTerritoryHistoryVID])
REFERENCES [datavault].[SalesTerritoryHistoryLINK] ([SalesTerritoryHistoryVID])
GO
