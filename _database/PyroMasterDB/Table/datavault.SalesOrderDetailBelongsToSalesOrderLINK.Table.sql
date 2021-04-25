SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailBelongsToSalesOrderLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SalesOrderDetailBelongsToSalesOrderLINK](
	[SalesOrderDetailBelongsToSalesOrderVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[SalesOrderDetailVID] [bigint] NOT NULL,
	[SalesOrderVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesOrderDetailBelongsToSalesOrderVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderDetailVID] ASC,
	[SalesOrderVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderDetailVID] ASC,
	[SalesOrderVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderDetailVID] ASC,
	[SalesOrderVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__3D73F9C2]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailBelongsToSalesOrderLINK]'))
ALTER TABLE [datavault].[SalesOrderDetailBelongsToSalesOrderLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderDetailVID])
REFERENCES [datavault].[SalesOrderDetailHUB] ([SalesOrderDetailVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__3E681DFB]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailBelongsToSalesOrderLINK]'))
ALTER TABLE [datavault].[SalesOrderDetailBelongsToSalesOrderLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__469E3CA0]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailBelongsToSalesOrderLINK]'))
ALTER TABLE [datavault].[SalesOrderDetailBelongsToSalesOrderLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderDetailVID])
REFERENCES [datavault].[SalesOrderDetailHUB] ([SalesOrderDetailVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__479260D9]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailBelongsToSalesOrderLINK]'))
ALTER TABLE [datavault].[SalesOrderDetailBelongsToSalesOrderLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__4905A7FF]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailBelongsToSalesOrderLINK]'))
ALTER TABLE [datavault].[SalesOrderDetailBelongsToSalesOrderLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderDetailVID])
REFERENCES [datavault].[SalesOrderDetailHUB] ([SalesOrderDetailVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__49F9CC38]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailBelongsToSalesOrderLINK]'))
ALTER TABLE [datavault].[SalesOrderDetailBelongsToSalesOrderLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
