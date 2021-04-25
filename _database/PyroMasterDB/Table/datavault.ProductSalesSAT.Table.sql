SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductSalesSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductSalesSAT](
	[ProductVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[ListPrice] [money] NOT NULL,
	[SellStartDate] [datetime] NOT NULL,
	[DiscontinuedDate] [datetime] NULL,
	[SellEndDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductSa__Produ__259C7031]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductSalesSAT]'))
ALTER TABLE [datavault].[ProductSalesSAT]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductSa__Produ__2EC6B30F]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductSalesSAT]'))
ALTER TABLE [datavault].[ProductSalesSAT]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductSa__Produ__312E1E6E]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductSalesSAT]'))
ALTER TABLE [datavault].[ProductSalesSAT]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
