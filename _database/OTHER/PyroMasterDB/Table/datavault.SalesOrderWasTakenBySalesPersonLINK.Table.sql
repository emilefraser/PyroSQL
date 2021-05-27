SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SalesOrderWasTakenBySalesPersonLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SalesOrderWasTakenBySalesPersonLINK](
	[SalesOrderWasTakenBySalesPersonVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[SalesOrderVID] [bigint] NOT NULL,
	[SalesPersonVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesOrderWasTakenBySalesPersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderVID] ASC,
	[SalesPersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderVID] ASC,
	[SalesPersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderVID] ASC,
	[SalesPersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__4CB63D52]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderWasTakenBySalesPersonLINK]'))
ALTER TABLE [datavault].[SalesOrderWasTakenBySalesPersonLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__4DAA618B]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderWasTakenBySalesPersonLINK]'))
ALTER TABLE [datavault].[SalesOrderWasTakenBySalesPersonLINK]  WITH CHECK ADD FOREIGN KEY([SalesPersonVID])
REFERENCES [datavault].[SalesPersonHUB] ([SalesPersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__55E08030]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderWasTakenBySalesPersonLINK]'))
ALTER TABLE [datavault].[SalesOrderWasTakenBySalesPersonLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__56D4A469]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderWasTakenBySalesPersonLINK]'))
ALTER TABLE [datavault].[SalesOrderWasTakenBySalesPersonLINK]  WITH CHECK ADD FOREIGN KEY([SalesPersonVID])
REFERENCES [datavault].[SalesPersonHUB] ([SalesPersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__5847EB8F]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderWasTakenBySalesPersonLINK]'))
ALTER TABLE [datavault].[SalesOrderWasTakenBySalesPersonLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__593C0FC8]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderWasTakenBySalesPersonLINK]'))
ALTER TABLE [datavault].[SalesOrderWasTakenBySalesPersonLINK]  WITH CHECK ADD FOREIGN KEY([SalesPersonVID])
REFERENCES [datavault].[SalesPersonHUB] ([SalesPersonVID])
GO
