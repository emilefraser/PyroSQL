SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[StoreIsAKindOfBusinessEntityLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[StoreIsAKindOfBusinessEntityLINK](
	[StoreIsAKindOfBusinessEntityVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[BusinessEntityVID] [bigint] NOT NULL,
	[StoreVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[StoreIsAKindOfBusinessEntityVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[StoreVID] ASC,
	[BusinessEntityVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[StoreVID] ASC,
	[BusinessEntityVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[StoreVID] ASC,
	[BusinessEntityVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__StoreIsAK__Busin__62A57E71]') AND parent_object_id = OBJECT_ID(N'[datavault].[StoreIsAKindOfBusinessEntityLINK]'))
ALTER TABLE [datavault].[StoreIsAKindOfBusinessEntityLINK]  WITH CHECK ADD FOREIGN KEY([BusinessEntityVID])
REFERENCES [datavault].[BusinessEntityHUB] ([BusinessEntityVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__StoreIsAK__Busin__6BCFC14F]') AND parent_object_id = OBJECT_ID(N'[datavault].[StoreIsAKindOfBusinessEntityLINK]'))
ALTER TABLE [datavault].[StoreIsAKindOfBusinessEntityLINK]  WITH CHECK ADD FOREIGN KEY([BusinessEntityVID])
REFERENCES [datavault].[BusinessEntityHUB] ([BusinessEntityVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__StoreIsAK__Busin__6E372CAE]') AND parent_object_id = OBJECT_ID(N'[datavault].[StoreIsAKindOfBusinessEntityLINK]'))
ALTER TABLE [datavault].[StoreIsAKindOfBusinessEntityLINK]  WITH CHECK ADD FOREIGN KEY([BusinessEntityVID])
REFERENCES [datavault].[BusinessEntityHUB] ([BusinessEntityVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__StoreIsAK__Store__6399A2AA]') AND parent_object_id = OBJECT_ID(N'[datavault].[StoreIsAKindOfBusinessEntityLINK]'))
ALTER TABLE [datavault].[StoreIsAKindOfBusinessEntityLINK]  WITH CHECK ADD FOREIGN KEY([StoreVID])
REFERENCES [datavault].[StoreHUB] ([StoreVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__StoreIsAK__Store__6CC3E588]') AND parent_object_id = OBJECT_ID(N'[datavault].[StoreIsAKindOfBusinessEntityLINK]'))
ALTER TABLE [datavault].[StoreIsAKindOfBusinessEntityLINK]  WITH CHECK ADD FOREIGN KEY([StoreVID])
REFERENCES [datavault].[StoreHUB] ([StoreVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__StoreIsAK__Store__6F2B50E7]') AND parent_object_id = OBJECT_ID(N'[datavault].[StoreIsAKindOfBusinessEntityLINK]'))
ALTER TABLE [datavault].[StoreIsAKindOfBusinessEntityLINK]  WITH CHECK ADD FOREIGN KEY([StoreVID])
REFERENCES [datavault].[StoreHUB] ([StoreVID])
GO
