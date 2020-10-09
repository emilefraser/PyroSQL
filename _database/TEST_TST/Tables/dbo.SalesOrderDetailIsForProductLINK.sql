SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SalesOrderDetailIsForProductLINK](
	[SalesOrderDetailIsForProductVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[ProductVID] [bigint] NOT NULL,
	[SalesOrderDetailVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
