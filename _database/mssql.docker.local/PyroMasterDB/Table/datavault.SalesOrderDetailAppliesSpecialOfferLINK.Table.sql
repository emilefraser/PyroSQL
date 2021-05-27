SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailAppliesSpecialOfferLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SalesOrderDetailAppliesSpecialOfferLINK](
	[SalesOrderDetailAppliesSpecialOfferVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[SalesOrderDetailVID] [bigint] NOT NULL,
	[SpecialOfferVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesOrderDetailAppliesSpecialOfferVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderDetailVID] ASC,
	[SpecialOfferVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderDetailVID] ASC,
	[SpecialOfferVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderDetailVID] ASC,
	[SpecialOfferVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__3B8BB150]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailAppliesSpecialOfferLINK]'))
ALTER TABLE [datavault].[SalesOrderDetailAppliesSpecialOfferLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderDetailVID])
REFERENCES [datavault].[SalesOrderDetailHUB] ([SalesOrderDetailVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__44B5F42E]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailAppliesSpecialOfferLINK]'))
ALTER TABLE [datavault].[SalesOrderDetailAppliesSpecialOfferLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderDetailVID])
REFERENCES [datavault].[SalesOrderDetailHUB] ([SalesOrderDetailVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__471D5F8D]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailAppliesSpecialOfferLINK]'))
ALTER TABLE [datavault].[SalesOrderDetailAppliesSpecialOfferLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderDetailVID])
REFERENCES [datavault].[SalesOrderDetailHUB] ([SalesOrderDetailVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Speci__3C7FD589]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailAppliesSpecialOfferLINK]'))
ALTER TABLE [datavault].[SalesOrderDetailAppliesSpecialOfferLINK]  WITH CHECK ADD FOREIGN KEY([SpecialOfferVID])
REFERENCES [datavault].[SpecialOfferHUB] ([SpecialOfferVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Speci__45AA1867]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailAppliesSpecialOfferLINK]'))
ALTER TABLE [datavault].[SalesOrderDetailAppliesSpecialOfferLINK]  WITH CHECK ADD FOREIGN KEY([SpecialOfferVID])
REFERENCES [datavault].[SpecialOfferHUB] ([SpecialOfferVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Speci__481183C6]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailAppliesSpecialOfferLINK]'))
ALTER TABLE [datavault].[SalesOrderDetailAppliesSpecialOfferLINK]  WITH CHECK ADD FOREIGN KEY([SpecialOfferVID])
REFERENCES [datavault].[SpecialOfferHUB] ([SpecialOfferVID])
GO
