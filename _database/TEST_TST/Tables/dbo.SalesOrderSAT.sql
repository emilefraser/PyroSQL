SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SalesOrderSAT](
	[SalesOrderVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[OnlineOrderFlag] [bit] NULL,
	[DueDate] [datetime] NOT NULL,
	[Freight] [money] NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[RevisionNumber] [tinyint] NOT NULL,
	[SalesOrderNumber] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ShipMethodID] [bigint] NOT NULL,
	[StatusSalesOrderStatusCode] [tinyint] NOT NULL,
	[SubTotal] [money] NOT NULL,
	[TaxAmt] [money] NOT NULL,
	[AccountNumber] [varchar](16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreditCardApprovalCode] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PurchaseOrderNumber] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalesOrderComment] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ShipDate] [datetime] NULL
) ON [PRIMARY]

GO
