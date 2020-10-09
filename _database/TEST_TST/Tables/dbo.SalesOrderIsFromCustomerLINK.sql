SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SalesOrderIsFromCustomerLINK](
	[SalesOrderIsFromCustomerVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[CustomerVID] [bigint] NOT NULL,
	[SalesOrderVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
