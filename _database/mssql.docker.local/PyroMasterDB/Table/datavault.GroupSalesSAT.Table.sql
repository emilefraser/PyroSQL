SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[GroupSalesSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[GroupSalesSAT](
	[ProductVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[StandardCost] [money] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__GroupSale__Produ__07ACE5EE]') AND parent_object_id = OBJECT_ID(N'[datavault].[GroupSalesSAT]'))
ALTER TABLE [datavault].[GroupSalesSAT]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__GroupSale__Produ__0A14514D]') AND parent_object_id = OBJECT_ID(N'[datavault].[GroupSalesSAT]'))
ALTER TABLE [datavault].[GroupSalesSAT]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__GroupSale__Produ__7E82A310]') AND parent_object_id = OBJECT_ID(N'[datavault].[GroupSalesSAT]'))
ALTER TABLE [datavault].[GroupSalesSAT]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
