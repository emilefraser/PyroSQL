SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SalesOrderDetailHUB](
	[SalesOrderDetailVID] [bigint] IDENTITY(1,1) NOT NULL,
	[SalesOrderID] [bigint] NOT NULL,
	[SalesOrderDetailID] [bigint] NOT NULL
) ON [PRIMARY]

GO
