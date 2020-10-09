SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[OrderDetails](
	[orderid] [int] NOT NULL,
	[productid] [int] NOT NULL,
	[unitprice] [money] NOT NULL,
	[qty] [smallint] NOT NULL,
	[discount] [numeric](4, 3) NOT NULL
) ON [PRIMARY]

GO
