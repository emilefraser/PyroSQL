SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductCostHistorySAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductCostHistorySAT](
	[ProductCostHistoryVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[StandardCost] [money] NOT NULL,
	[EndDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductCostHistoryVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductCo__Produ__0DC4E6A0]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductCostHistorySAT]'))
ALTER TABLE [datavault].[ProductCostHistorySAT]  WITH CHECK ADD FOREIGN KEY([ProductCostHistoryVID])
REFERENCES [datavault].[ProductCostHistoryHUB] ([ProductCostHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductCo__Produ__16EF297E]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductCostHistorySAT]'))
ALTER TABLE [datavault].[ProductCostHistorySAT]  WITH CHECK ADD FOREIGN KEY([ProductCostHistoryVID])
REFERENCES [datavault].[ProductCostHistoryHUB] ([ProductCostHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductCo__Produ__195694DD]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductCostHistorySAT]'))
ALTER TABLE [datavault].[ProductCostHistorySAT]  WITH CHECK ADD FOREIGN KEY([ProductCostHistoryVID])
REFERENCES [datavault].[ProductCostHistoryHUB] ([ProductCostHistoryVID])
GO
