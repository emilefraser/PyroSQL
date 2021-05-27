SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SalesOrderBillsCreditCardLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SalesOrderBillsCreditCardLINK](
	[SalesOrderBillsCreditCardVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[SalesOrderVID] [bigint] NOT NULL,
	[CreditCardVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesOrderBillsCreditCardVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderVID] ASC,
	[CreditCardVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderVID] ASC,
	[CreditCardVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderVID] ASC,
	[CreditCardVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Credi__37BB206C]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderBillsCreditCardLINK]'))
ALTER TABLE [datavault].[SalesOrderBillsCreditCardLINK]  WITH CHECK ADD FOREIGN KEY([CreditCardVID])
REFERENCES [datavault].[CreditCardHUB] ([CreditCardVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Credi__40E5634A]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderBillsCreditCardLINK]'))
ALTER TABLE [datavault].[SalesOrderBillsCreditCardLINK]  WITH CHECK ADD FOREIGN KEY([CreditCardVID])
REFERENCES [datavault].[CreditCardHUB] ([CreditCardVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Credi__434CCEA9]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderBillsCreditCardLINK]'))
ALTER TABLE [datavault].[SalesOrderBillsCreditCardLINK]  WITH CHECK ADD FOREIGN KEY([CreditCardVID])
REFERENCES [datavault].[CreditCardHUB] ([CreditCardVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__38AF44A5]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderBillsCreditCardLINK]'))
ALTER TABLE [datavault].[SalesOrderBillsCreditCardLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__41D98783]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderBillsCreditCardLINK]'))
ALTER TABLE [datavault].[SalesOrderBillsCreditCardLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__4440F2E2]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderBillsCreditCardLINK]'))
ALTER TABLE [datavault].[SalesOrderBillsCreditCardLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
