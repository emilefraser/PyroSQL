SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductListPriceHistoryInvolvesProductLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductListPriceHistoryInvolvesProductLINK](
	[ProductListPriceHistoryInvolvesProductVI] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[ProductListPriceHistoryVID] [bigint] NOT NULL,
	[ProductVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductListPriceHistoryInvolvesProductVI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductListPriceHistoryVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductListPriceHistoryVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductListPriceHistoryVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductLi__Produ__174E50DA]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductListPriceHistoryInvolvesProductLINK]'))
ALTER TABLE [datavault].[ProductListPriceHistoryInvolvesProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductListPriceHistoryVID])
REFERENCES [datavault].[ProductListPriceHistoryHUB] ([ProductListPriceHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductLi__Produ__18427513]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductListPriceHistoryInvolvesProductLINK]'))
ALTER TABLE [datavault].[ProductListPriceHistoryInvolvesProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductLi__Produ__207893B8]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductListPriceHistoryInvolvesProductLINK]'))
ALTER TABLE [datavault].[ProductListPriceHistoryInvolvesProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductListPriceHistoryVID])
REFERENCES [datavault].[ProductListPriceHistoryHUB] ([ProductListPriceHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductLi__Produ__216CB7F1]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductListPriceHistoryInvolvesProductLINK]'))
ALTER TABLE [datavault].[ProductListPriceHistoryInvolvesProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductLi__Produ__22DFFF17]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductListPriceHistoryInvolvesProductLINK]'))
ALTER TABLE [datavault].[ProductListPriceHistoryInvolvesProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductListPriceHistoryVID])
REFERENCES [datavault].[ProductListPriceHistoryHUB] ([ProductListPriceHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductLi__Produ__23D42350]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductListPriceHistoryInvolvesProductLINK]'))
ALTER TABLE [datavault].[ProductListPriceHistoryInvolvesProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
