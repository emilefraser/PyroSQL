SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SalesOrderSalesReasonInvolvesSalesOrderLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SalesOrderSalesReasonInvolvesSalesOrderLINK](
	[SalesOrderSalesReasonInvolvesSalesOrderV] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[SalesOrderSalesReasonVID] [bigint] NOT NULL,
	[SalesOrderVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesOrderSalesReasonInvolvesSalesOrderV] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderSalesReasonVID] ASC,
	[SalesOrderVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderSalesReasonVID] ASC,
	[SalesOrderVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderSalesReasonVID] ASC,
	[SalesOrderVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__49D9D0A7]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderSalesReasonInvolvesSalesOrderLINK]'))
ALTER TABLE [datavault].[SalesOrderSalesReasonInvolvesSalesOrderLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderSalesReasonVID])
REFERENCES [datavault].[SalesOrderSalesReasonHUB] ([SalesOrderSalesReasonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__4ACDF4E0]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderSalesReasonInvolvesSalesOrderLINK]'))
ALTER TABLE [datavault].[SalesOrderSalesReasonInvolvesSalesOrderLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__53041385]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderSalesReasonInvolvesSalesOrderLINK]'))
ALTER TABLE [datavault].[SalesOrderSalesReasonInvolvesSalesOrderLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderSalesReasonVID])
REFERENCES [datavault].[SalesOrderSalesReasonHUB] ([SalesOrderSalesReasonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__53F837BE]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderSalesReasonInvolvesSalesOrderLINK]'))
ALTER TABLE [datavault].[SalesOrderSalesReasonInvolvesSalesOrderLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__556B7EE4]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderSalesReasonInvolvesSalesOrderLINK]'))
ALTER TABLE [datavault].[SalesOrderSalesReasonInvolvesSalesOrderLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderSalesReasonVID])
REFERENCES [datavault].[SalesOrderSalesReasonHUB] ([SalesOrderSalesReasonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__565FA31D]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderSalesReasonInvolvesSalesOrderLINK]'))
ALTER TABLE [datavault].[SalesOrderSalesReasonInvolvesSalesOrderLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
