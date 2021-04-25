SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Sales__ShoppingCartItem]') AND type in (N'U'))
BEGIN
CREATE TABLE [AdventureWorks].[Sales__ShoppingCartItem](
	[ShoppingCartItemID] [int] NOT NULL,
	[ShoppingCartID] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Quantity] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]
END
GO
