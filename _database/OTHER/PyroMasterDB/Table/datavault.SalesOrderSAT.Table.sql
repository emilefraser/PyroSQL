SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SalesOrderSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SalesOrderSAT](
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
	[ShipDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesOrderVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__4BC21919]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderSAT]'))
ALTER TABLE [datavault].[SalesOrderSAT]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__54EC5BF7]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderSAT]'))
ALTER TABLE [datavault].[SalesOrderSAT]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__5753C756]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderSAT]'))
ALTER TABLE [datavault].[SalesOrderSAT]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__SalesOrde__Statu__012A0591]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderSAT]'))
ALTER TABLE [datavault].[SalesOrderSAT]  WITH CHECK ADD CHECK  (([StatusSalesOrderStatusCode]>=(1) AND [StatusSalesOrderStatusCode]<=(8)))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__SalesOrde__Statu__0683B78B]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderSAT]'))
ALTER TABLE [datavault].[SalesOrderSAT]  WITH CHECK ADD CHECK  (([StatusSalesOrderStatusCode]>=(1) AND [StatusSalesOrderStatusCode]<=(8)))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__SalesOrde__Statu__08EB22EA]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderSAT]'))
ALTER TABLE [datavault].[SalesOrderSAT]  WITH CHECK ADD CHECK  (([StatusSalesOrderStatusCode]>=(1) AND [StatusSalesOrderStatusCode]<=(8)))
GO
