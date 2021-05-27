SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductInventoryLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductInventoryLINK](
	[ProductInventoryVID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProductVID] [bigint] NOT NULL,
	[LocationVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductInventoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductVID] ASC,
	[LocationVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductVID] ASC,
	[LocationVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductVID] ASC,
	[LocationVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductIn__Locat__12899BBD]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductInventoryLINK]'))
ALTER TABLE [datavault].[ProductInventoryLINK]  WITH CHECK ADD FOREIGN KEY([LocationVID])
REFERENCES [datavault].[LocationHUB] ([LocationVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductIn__Locat__1BB3DE9B]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductInventoryLINK]'))
ALTER TABLE [datavault].[ProductInventoryLINK]  WITH CHECK ADD FOREIGN KEY([LocationVID])
REFERENCES [datavault].[LocationHUB] ([LocationVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductIn__Locat__1E1B49FA]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductInventoryLINK]'))
ALTER TABLE [datavault].[ProductInventoryLINK]  WITH CHECK ADD FOREIGN KEY([LocationVID])
REFERENCES [datavault].[LocationHUB] ([LocationVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductIn__Produ__137DBFF6]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductInventoryLINK]'))
ALTER TABLE [datavault].[ProductInventoryLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductIn__Produ__1CA802D4]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductInventoryLINK]'))
ALTER TABLE [datavault].[ProductInventoryLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductIn__Produ__1F0F6E33]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductInventoryLINK]'))
ALTER TABLE [datavault].[ProductInventoryLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
