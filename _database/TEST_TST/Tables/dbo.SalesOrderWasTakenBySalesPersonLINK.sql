SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SalesOrderWasTakenBySalesPersonLINK](
	[SalesOrderWasTakenBySalesPersonVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[SalesOrderVID] [bigint] NOT NULL,
	[SalesPersonVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
