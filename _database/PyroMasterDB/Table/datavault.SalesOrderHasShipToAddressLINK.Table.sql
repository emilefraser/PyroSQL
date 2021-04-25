SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SalesOrderHasShipToAddressLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SalesOrderHasShipToAddressLINK](
	[SalesOrderHasShipToAddressVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[SalesOrderVID] [bigint] NOT NULL,
	[ShipToAddressVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesOrderHasShipToAddressVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderVID] ASC,
	[ShipToAddressVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderVID] ASC,
	[ShipToAddressVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderVID] ASC,
	[ShipToAddressVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__4420F751]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderHasShipToAddressLINK]'))
ALTER TABLE [datavault].[SalesOrderHasShipToAddressLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__4D4B3A2F]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderHasShipToAddressLINK]'))
ALTER TABLE [datavault].[SalesOrderHasShipToAddressLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__4FB2A58E]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderHasShipToAddressLINK]'))
ALTER TABLE [datavault].[SalesOrderHasShipToAddressLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__ShipT__45151B8A]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderHasShipToAddressLINK]'))
ALTER TABLE [datavault].[SalesOrderHasShipToAddressLINK]  WITH CHECK ADD FOREIGN KEY([ShipToAddressVID])
REFERENCES [datavault].[AddressHUB] ([AddressVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__ShipT__4E3F5E68]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderHasShipToAddressLINK]'))
ALTER TABLE [datavault].[SalesOrderHasShipToAddressLINK]  WITH CHECK ADD FOREIGN KEY([ShipToAddressVID])
REFERENCES [datavault].[AddressHUB] ([AddressVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__ShipT__50A6C9C7]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderHasShipToAddressLINK]'))
ALTER TABLE [datavault].[SalesOrderHasShipToAddressLINK]  WITH CHECK ADD FOREIGN KEY([ShipToAddressVID])
REFERENCES [datavault].[AddressHUB] ([AddressVID])
GO
