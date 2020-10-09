SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[SalesOrderHeaderSalesReason](
	[SalesOrderID] [int] NOT NULL,
	[SalesReasonID] [int] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
