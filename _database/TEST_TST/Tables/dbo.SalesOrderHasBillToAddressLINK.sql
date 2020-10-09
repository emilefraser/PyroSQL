SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SalesOrderHasBillToAddressLINK](
	[SalesOrderHasBillToAddressVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[BillToAddressVID] [bigint] NOT NULL,
	[SalesOrderVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
