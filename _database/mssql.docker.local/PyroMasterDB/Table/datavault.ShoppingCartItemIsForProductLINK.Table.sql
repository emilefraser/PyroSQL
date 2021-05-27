SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ShoppingCartItemIsForProductLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ShoppingCartItemIsForProductLINK](
	[ShoppingCartItemIsForProductVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[ProductVID] [bigint] NOT NULL,
	[ShoppingCartItemVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ShoppingCartItemIsForProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ShoppingCartItemVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ShoppingCartItemVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ShoppingCartItemVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ShoppingC__Produ__5CECA51B]') AND parent_object_id = OBJECT_ID(N'[datavault].[ShoppingCartItemIsForProductLINK]'))
ALTER TABLE [datavault].[ShoppingCartItemIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ShoppingC__Produ__6616E7F9]') AND parent_object_id = OBJECT_ID(N'[datavault].[ShoppingCartItemIsForProductLINK]'))
ALTER TABLE [datavault].[ShoppingCartItemIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ShoppingC__Produ__687E5358]') AND parent_object_id = OBJECT_ID(N'[datavault].[ShoppingCartItemIsForProductLINK]'))
ALTER TABLE [datavault].[ShoppingCartItemIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ShoppingC__Shopp__5DE0C954]') AND parent_object_id = OBJECT_ID(N'[datavault].[ShoppingCartItemIsForProductLINK]'))
ALTER TABLE [datavault].[ShoppingCartItemIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([ShoppingCartItemVID])
REFERENCES [datavault].[ShoppingCartItemHUB] ([ShoppingCartItemVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ShoppingC__Shopp__670B0C32]') AND parent_object_id = OBJECT_ID(N'[datavault].[ShoppingCartItemIsForProductLINK]'))
ALTER TABLE [datavault].[ShoppingCartItemIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([ShoppingCartItemVID])
REFERENCES [datavault].[ShoppingCartItemHUB] ([ShoppingCartItemVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ShoppingC__Shopp__69727791]') AND parent_object_id = OBJECT_ID(N'[datavault].[ShoppingCartItemIsForProductLINK]'))
ALTER TABLE [datavault].[ShoppingCartItemIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([ShoppingCartItemVID])
REFERENCES [datavault].[ShoppingCartItemHUB] ([ShoppingCartItemVID])
GO
