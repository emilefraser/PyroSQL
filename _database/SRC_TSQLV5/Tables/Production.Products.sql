SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[Products](
	[productid] [int] IDENTITY(1,1) NOT NULL,
	[productname] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[supplierid] [int] NOT NULL,
	[categoryid] [int] NOT NULL,
	[unitprice] [money] NOT NULL,
	[discontinued] [bit] NOT NULL
) ON [PRIMARY]

GO
