SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[CustomerIsStoreLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[CustomerIsStoreLINK](
	[CustomerIsStoreVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[CustomerVID] [bigint] NOT NULL,
	[StoreVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CustomerIsStoreVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CustomerVID] ASC,
	[StoreVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CustomerVID] ASC,
	[StoreVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CustomerVID] ASC,
	[StoreVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CustomerI__Custo__65B6F546]') AND parent_object_id = OBJECT_ID(N'[datavault].[CustomerIsStoreLINK]'))
ALTER TABLE [datavault].[CustomerIsStoreLINK]  WITH CHECK ADD FOREIGN KEY([CustomerVID])
REFERENCES [datavault].[CustomerHUB] ([CustomerVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CustomerI__Custo__6EE13824]') AND parent_object_id = OBJECT_ID(N'[datavault].[CustomerIsStoreLINK]'))
ALTER TABLE [datavault].[CustomerIsStoreLINK]  WITH CHECK ADD FOREIGN KEY([CustomerVID])
REFERENCES [datavault].[CustomerHUB] ([CustomerVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CustomerI__Custo__7148A383]') AND parent_object_id = OBJECT_ID(N'[datavault].[CustomerIsStoreLINK]'))
ALTER TABLE [datavault].[CustomerIsStoreLINK]  WITH CHECK ADD FOREIGN KEY([CustomerVID])
REFERENCES [datavault].[CustomerHUB] ([CustomerVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CustomerI__Store__66AB197F]') AND parent_object_id = OBJECT_ID(N'[datavault].[CustomerIsStoreLINK]'))
ALTER TABLE [datavault].[CustomerIsStoreLINK]  WITH CHECK ADD FOREIGN KEY([StoreVID])
REFERENCES [datavault].[StoreHUB] ([StoreVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CustomerI__Store__6FD55C5D]') AND parent_object_id = OBJECT_ID(N'[datavault].[CustomerIsStoreLINK]'))
ALTER TABLE [datavault].[CustomerIsStoreLINK]  WITH CHECK ADD FOREIGN KEY([StoreVID])
REFERENCES [datavault].[StoreHUB] ([StoreVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CustomerI__Store__723CC7BC]') AND parent_object_id = OBJECT_ID(N'[datavault].[CustomerIsStoreLINK]'))
ALTER TABLE [datavault].[CustomerIsStoreLINK]  WITH CHECK ADD FOREIGN KEY([StoreVID])
REFERENCES [datavault].[StoreHUB] ([StoreVID])
GO
