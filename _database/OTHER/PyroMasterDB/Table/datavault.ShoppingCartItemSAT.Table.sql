SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ShoppingCartItemSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ShoppingCartItemSAT](
	[ShoppingCartItemVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[Quantity] [int] NOT NULL,
	[ShoppingCartID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ShoppingCartItemVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ShoppingC__Shopp__5ED4ED8D]') AND parent_object_id = OBJECT_ID(N'[datavault].[ShoppingCartItemSAT]'))
ALTER TABLE [datavault].[ShoppingCartItemSAT]  WITH CHECK ADD FOREIGN KEY([ShoppingCartItemVID])
REFERENCES [datavault].[ShoppingCartItemHUB] ([ShoppingCartItemVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ShoppingC__Shopp__67FF306B]') AND parent_object_id = OBJECT_ID(N'[datavault].[ShoppingCartItemSAT]'))
ALTER TABLE [datavault].[ShoppingCartItemSAT]  WITH CHECK ADD FOREIGN KEY([ShoppingCartItemVID])
REFERENCES [datavault].[ShoppingCartItemHUB] ([ShoppingCartItemVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ShoppingC__Shopp__6A669BCA]') AND parent_object_id = OBJECT_ID(N'[datavault].[ShoppingCartItemSAT]'))
ALTER TABLE [datavault].[ShoppingCartItemSAT]  WITH CHECK ADD FOREIGN KEY([ShoppingCartItemVID])
REFERENCES [datavault].[ShoppingCartItemHUB] ([ShoppingCartItemVID])
GO
