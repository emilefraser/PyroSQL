SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SalesOrderDetailSAT](
	[SalesOrderDetailVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[OrderQty] [int] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[UnitPriceDiscount] [money] NOT NULL,
	[CarrierTrackingNumber] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
