SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[Orders](
	[orderid] [int] IDENTITY(1,1) NOT NULL,
	[custid] [int] NULL,
	[empid] [int] NOT NULL,
	[orderdate] [date] NOT NULL,
	[requireddate] [date] NOT NULL,
	[shippeddate] [date] NULL,
	[shipperid] [int] NOT NULL,
	[freight] [money] NOT NULL,
	[shipname] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[shipaddress] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[shipcity] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[shipregion] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[shippostalcode] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[shipcountry] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
