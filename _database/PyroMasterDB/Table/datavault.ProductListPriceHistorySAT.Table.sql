SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductListPriceHistorySAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductListPriceHistorySAT](
	[ProductListPriceHistoryVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[ListPrice] [money] NOT NULL,
	[EndDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductListPriceHistoryVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductLi__Produ__1936994C]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductListPriceHistorySAT]'))
ALTER TABLE [datavault].[ProductListPriceHistorySAT]  WITH CHECK ADD FOREIGN KEY([ProductListPriceHistoryVID])
REFERENCES [datavault].[ProductListPriceHistoryHUB] ([ProductListPriceHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductLi__Produ__2260DC2A]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductListPriceHistorySAT]'))
ALTER TABLE [datavault].[ProductListPriceHistorySAT]  WITH CHECK ADD FOREIGN KEY([ProductListPriceHistoryVID])
REFERENCES [datavault].[ProductListPriceHistoryHUB] ([ProductListPriceHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductLi__Produ__24C84789]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductListPriceHistorySAT]'))
ALTER TABLE [datavault].[ProductListPriceHistorySAT]  WITH CHECK ADD FOREIGN KEY([ProductListPriceHistoryVID])
REFERENCES [datavault].[ProductListPriceHistoryHUB] ([ProductListPriceHistoryVID])
GO
