SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [HR].[Employees](
	[empid] [int] IDENTITY(1,1) NOT NULL,
	[lastname] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[firstname] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[title] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[titleofcourtesy] [nvarchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[birthdate] [date] NOT NULL,
	[hiredate] [date] NOT NULL,
	[address] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[city] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[region] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[postalcode] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[country] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[phone] [nvarchar](24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[mgrid] [int] NULL
) ON [PRIMARY]

GO
