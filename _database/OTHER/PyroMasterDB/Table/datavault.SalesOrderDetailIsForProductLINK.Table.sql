SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailIsForProductLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SalesOrderDetailIsForProductLINK](
	[SalesOrderDetailIsForProductVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[ProductVID] [bigint] NOT NULL,
	[SalesOrderDetailVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesOrderDetailIsForProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderDetailVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderDetailVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderDetailVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Produ__3F5C4234]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailIsForProductLINK]'))
ALTER TABLE [datavault].[SalesOrderDetailIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Produ__48868512]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailIsForProductLINK]'))
ALTER TABLE [datavault].[SalesOrderDetailIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Produ__4AEDF071]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailIsForProductLINK]'))
ALTER TABLE [datavault].[SalesOrderDetailIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__4050666D]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailIsForProductLINK]'))
ALTER TABLE [datavault].[SalesOrderDetailIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderDetailVID])
REFERENCES [datavault].[SalesOrderDetailHUB] ([SalesOrderDetailVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__497AA94B]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailIsForProductLINK]'))
ALTER TABLE [datavault].[SalesOrderDetailIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderDetailVID])
REFERENCES [datavault].[SalesOrderDetailHUB] ([SalesOrderDetailVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__4BE214AA]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderDetailIsForProductLINK]'))
ALTER TABLE [datavault].[SalesOrderDetailIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderDetailVID])
REFERENCES [datavault].[SalesOrderDetailHUB] ([SalesOrderDetailVID])
GO
