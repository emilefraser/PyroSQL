SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[DatabaseTechnologyType](
	[DatabaseTechnologyTypeID] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseTechnologyTypeCode] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DatabaseTechnologyTypeName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
