SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [CONFIG].[Company](
	[CompanyID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CompanyName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CompanyLogoOLD] [varbinary](max) NULL,
	[CompanyLogo] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReportingCompanyLogo] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
