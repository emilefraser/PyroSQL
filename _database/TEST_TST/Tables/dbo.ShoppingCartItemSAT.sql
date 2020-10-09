SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ShoppingCartItemSAT](
	[ShoppingCartItemVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[Quantity] [int] NOT NULL,
	[ShoppingCartID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
