SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [XMLDATA].[ApplicationObjectModel](
	[ApplicationID] [smallint] IDENTITY(1,1) NOT NULL,
	[Prefix] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ApplicationName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ApplicationVersion] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
