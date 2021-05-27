SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SalesOrderDetailSAT](
	[SalesOrderDetailVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[OrderQty] [int] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[UnitPriceDiscount] [money] NOT NULL,
	[CarrierTrackingNumber] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesOrderDetailVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__41448AA6]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailSAT]'))
ALTER TABLE [datavault].[SalesOrderDetailSAT]  WITH CHECK ADD FOREIGN KEY([SalesOrderDetailVID])
REFERENCES [datavault].[SalesOrderDetailHUB] ([SalesOrderDetailVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__4A6ECD84]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailSAT]'))
ALTER TABLE [datavault].[SalesOrderDetailSAT]  WITH CHECK ADD FOREIGN KEY([SalesOrderDetailVID])
REFERENCES [datavault].[SalesOrderDetailHUB] ([SalesOrderDetailVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__4CD638E3]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailSAT]'))
ALTER TABLE [datavault].[SalesOrderDetailSAT]  WITH CHECK ADD FOREIGN KEY([SalesOrderDetailVID])
REFERENCES [datavault].[SalesOrderDetailHUB] ([SalesOrderDetailVID])
GO
