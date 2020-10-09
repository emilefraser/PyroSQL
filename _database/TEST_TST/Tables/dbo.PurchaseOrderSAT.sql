SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PurchaseOrderSAT](
	[PurchaseOrderVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Freight] [money] NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[PurchaseOrderNumber] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[RevisionNumber] [tinyint] NOT NULL,
	[ShipMethodID] [bigint] NOT NULL,
	[StatusPurchaseOrderStatusCode] [tinyint] NOT NULL,
	[SubTotal] [money] NOT NULL,
	[TaxAmt] [money] NOT NULL,
	[ShipDate] [datetime] NULL
) ON [PRIMARY]

GO
