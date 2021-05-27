SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SalesToStoreAreManagedBySalesPersonLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SalesToStoreAreManagedBySalesPersonLINK](
	[SalesToStoreAreManagedBySalesPersonVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[StoreVID] [bigint] NOT NULL,
	[SalesPersonVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesToStoreAreManagedBySalesPersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[StoreVID] ASC,
	[SalesPersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[StoreVID] ASC,
	[SalesPersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[StoreVID] ASC,
	[SalesPersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesToSt__Sales__5A103870]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesToStoreAreManagedBySalesPersonLINK]'))
ALTER TABLE [datavault].[SalesToStoreAreManagedBySalesPersonLINK]  WITH CHECK ADD FOREIGN KEY([SalesPersonVID])
REFERENCES [datavault].[SalesPersonHUB] ([SalesPersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesToSt__Sales__633A7B4E]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesToStoreAreManagedBySalesPersonLINK]'))
ALTER TABLE [datavault].[SalesToStoreAreManagedBySalesPersonLINK]  WITH CHECK ADD FOREIGN KEY([SalesPersonVID])
REFERENCES [datavault].[SalesPersonHUB] ([SalesPersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesToSt__Sales__65A1E6AD]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesToStoreAreManagedBySalesPersonLINK]'))
ALTER TABLE [datavault].[SalesToStoreAreManagedBySalesPersonLINK]  WITH CHECK ADD FOREIGN KEY([SalesPersonVID])
REFERENCES [datavault].[SalesPersonHUB] ([SalesPersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesToSt__Store__5B045CA9]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesToStoreAreManagedBySalesPersonLINK]'))
ALTER TABLE [datavault].[SalesToStoreAreManagedBySalesPersonLINK]  WITH CHECK ADD FOREIGN KEY([StoreVID])
REFERENCES [datavault].[StoreHUB] ([StoreVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesToSt__Store__642E9F87]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesToStoreAreManagedBySalesPersonLINK]'))
ALTER TABLE [datavault].[SalesToStoreAreManagedBySalesPersonLINK]  WITH CHECK ADD FOREIGN KEY([StoreVID])
REFERENCES [datavault].[StoreHUB] ([StoreVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesToSt__Store__66960AE6]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesToStoreAreManagedBySalesPersonLINK]'))
ALTER TABLE [datavault].[SalesToStoreAreManagedBySalesPersonLINK]  WITH CHECK ADD FOREIGN KEY([StoreVID])
REFERENCES [datavault].[StoreHUB] ([StoreVID])
GO
