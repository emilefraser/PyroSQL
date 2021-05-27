SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SalesOrderHasBillToAddressLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SalesOrderHasBillToAddressLINK](
	[SalesOrderHasBillToAddressVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[BillToAddressVID] [bigint] NOT NULL,
	[SalesOrderVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesOrderHasBillToAddressVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderVID] ASC,
	[BillToAddressVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderVID] ASC,
	[BillToAddressVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderVID] ASC,
	[BillToAddressVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__BillT__4238AEDF]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderHasBillToAddressLINK]'))
ALTER TABLE [datavault].[SalesOrderHasBillToAddressLINK]  WITH CHECK ADD FOREIGN KEY([BillToAddressVID])
REFERENCES [datavault].[AddressHUB] ([AddressVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__BillT__4B62F1BD]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderHasBillToAddressLINK]'))
ALTER TABLE [datavault].[SalesOrderHasBillToAddressLINK]  WITH CHECK ADD FOREIGN KEY([BillToAddressVID])
REFERENCES [datavault].[AddressHUB] ([AddressVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__BillT__4DCA5D1C]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderHasBillToAddressLINK]'))
ALTER TABLE [datavault].[SalesOrderHasBillToAddressLINK]  WITH CHECK ADD FOREIGN KEY([BillToAddressVID])
REFERENCES [datavault].[AddressHUB] ([AddressVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__432CD318]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderHasBillToAddressLINK]'))
ALTER TABLE [datavault].[SalesOrderHasBillToAddressLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__4C5715F6]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderHasBillToAddressLINK]'))
ALTER TABLE [datavault].[SalesOrderHasBillToAddressLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__4EBE8155]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderHasBillToAddressLINK]'))
ALTER TABLE [datavault].[SalesOrderHasBillToAddressLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
