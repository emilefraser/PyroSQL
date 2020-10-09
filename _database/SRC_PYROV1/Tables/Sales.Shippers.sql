SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[Shippers](
	[shipperid] [int] IDENTITY(1,1) NOT NULL,
	[companyname] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[phone] [nvarchar](24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
