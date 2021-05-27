SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductIsOfProductModelLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductIsOfProductModelLINK](
	[ProductIsOfProductModelVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[ProductVID] [bigint] NOT NULL,
	[ProductModelVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductIsOfProductModelVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductVID] ASC,
	[ProductModelVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductVID] ASC,
	[ProductModelVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductVID] ASC,
	[ProductModelVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductIs__Produ__15660868]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductIsOfProductModelLINK]'))
ALTER TABLE [datavault].[ProductIsOfProductModelLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductIs__Produ__165A2CA1]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductIsOfProductModelLINK]'))
ALTER TABLE [datavault].[ProductIsOfProductModelLINK]  WITH CHECK ADD FOREIGN KEY([ProductModelVID])
REFERENCES [datavault].[ProductModelHUB] ([ProductModelVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductIs__Produ__1E904B46]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductIsOfProductModelLINK]'))
ALTER TABLE [datavault].[ProductIsOfProductModelLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductIs__Produ__1F846F7F]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductIsOfProductModelLINK]'))
ALTER TABLE [datavault].[ProductIsOfProductModelLINK]  WITH CHECK ADD FOREIGN KEY([ProductModelVID])
REFERENCES [datavault].[ProductModelHUB] ([ProductModelVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductIs__Produ__20F7B6A5]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductIsOfProductModelLINK]'))
ALTER TABLE [datavault].[ProductIsOfProductModelLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductIs__Produ__21EBDADE]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductIsOfProductModelLINK]'))
ALTER TABLE [datavault].[ProductIsOfProductModelLINK]  WITH CHECK ADD FOREIGN KEY([ProductModelVID])
REFERENCES [datavault].[ProductModelHUB] ([ProductModelVID])
GO
