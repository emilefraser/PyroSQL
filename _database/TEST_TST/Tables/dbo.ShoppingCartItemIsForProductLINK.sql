SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ShoppingCartItemIsForProductLINK](
	[ShoppingCartItemIsForProductVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[ProductVID] [bigint] NOT NULL,
	[ShoppingCartItemVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
