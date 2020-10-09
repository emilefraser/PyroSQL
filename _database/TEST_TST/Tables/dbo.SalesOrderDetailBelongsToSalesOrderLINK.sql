SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SalesOrderDetailBelongsToSalesOrderLINK](
	[SalesOrderDetailBelongsToSalesOrderVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[SalesOrderDetailVID] [bigint] NOT NULL,
	[SalesOrderVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
