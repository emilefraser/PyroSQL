SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductCostHistoryInvolvesProductLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductCostHistoryInvolvesProductLINK](
	[ProductCostHistoryInvolvesProductVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[ProductCostHistoryVID] [bigint] NOT NULL,
	[ProductVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductCostHistoryInvolvesProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductCostHistoryVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductCostHistoryVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductCostHistoryVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductCo__Produ__0BDC9E2E]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductCostHistoryInvolvesProductLINK]'))
ALTER TABLE [datavault].[ProductCostHistoryInvolvesProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductCostHistoryVID])
REFERENCES [datavault].[ProductCostHistoryHUB] ([ProductCostHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductCo__Produ__0CD0C267]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductCostHistoryInvolvesProductLINK]'))
ALTER TABLE [datavault].[ProductCostHistoryInvolvesProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductCo__Produ__1506E10C]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductCostHistoryInvolvesProductLINK]'))
ALTER TABLE [datavault].[ProductCostHistoryInvolvesProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductCostHistoryVID])
REFERENCES [datavault].[ProductCostHistoryHUB] ([ProductCostHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductCo__Produ__15FB0545]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductCostHistoryInvolvesProductLINK]'))
ALTER TABLE [datavault].[ProductCostHistoryInvolvesProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductCo__Produ__176E4C6B]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductCostHistoryInvolvesProductLINK]'))
ALTER TABLE [datavault].[ProductCostHistoryInvolvesProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductCostHistoryVID])
REFERENCES [datavault].[ProductCostHistoryHUB] ([ProductCostHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductCo__Produ__186270A4]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductCostHistoryInvolvesProductLINK]'))
ALTER TABLE [datavault].[ProductCostHistoryInvolvesProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
