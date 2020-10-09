SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[ShoppingCartItem](
	[ShoppingCartItemID] [int] IDENTITY(1,1) NOT NULL,
	[ShoppingCartID] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Quantity] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
