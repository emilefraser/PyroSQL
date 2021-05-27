SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SalesOrderIsFromCustomerLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SalesOrderIsFromCustomerLINK](
	[SalesOrderIsFromCustomerVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[CustomerVID] [bigint] NOT NULL,
	[SalesOrderVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesOrderIsFromCustomerVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderVID] ASC,
	[CustomerVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderVID] ASC,
	[CustomerVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderVID] ASC,
	[CustomerVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Custo__47F18835]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderIsFromCustomerLINK]'))
ALTER TABLE [datavault].[SalesOrderIsFromCustomerLINK]  WITH CHECK ADD FOREIGN KEY([CustomerVID])
REFERENCES [datavault].[CustomerHUB] ([CustomerVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Custo__511BCB13]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderIsFromCustomerLINK]'))
ALTER TABLE [datavault].[SalesOrderIsFromCustomerLINK]  WITH CHECK ADD FOREIGN KEY([CustomerVID])
REFERENCES [datavault].[CustomerHUB] ([CustomerVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Custo__53833672]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderIsFromCustomerLINK]'))
ALTER TABLE [datavault].[SalesOrderIsFromCustomerLINK]  WITH CHECK ADD FOREIGN KEY([CustomerVID])
REFERENCES [datavault].[CustomerHUB] ([CustomerVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__48E5AC6E]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderIsFromCustomerLINK]'))
ALTER TABLE [datavault].[SalesOrderIsFromCustomerLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__520FEF4C]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderIsFromCustomerLINK]'))
ALTER TABLE [datavault].[SalesOrderIsFromCustomerLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__54775AAB]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderIsFromCustomerLINK]'))
ALTER TABLE [datavault].[SalesOrderIsFromCustomerLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
