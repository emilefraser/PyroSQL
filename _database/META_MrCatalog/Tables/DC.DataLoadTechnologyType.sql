SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[DataLoadTechnologyType](
	[DataLoadTechnologyTypeID] [int] IDENTITY(1,1) NOT NULL,
	[DataLoadTechnologyTypeCode] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DataLoadTechnologyTypeName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
