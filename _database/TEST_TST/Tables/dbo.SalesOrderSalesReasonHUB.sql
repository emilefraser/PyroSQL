SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SalesOrderSalesReasonHUB](
	[SalesOrderSalesReasonVID] [bigint] IDENTITY(1,1) NOT NULL,
	[SalesOrderID] [bigint] NOT NULL,
	[SalesReasonID] [bigint] NOT NULL
) ON [PRIMARY]

GO
