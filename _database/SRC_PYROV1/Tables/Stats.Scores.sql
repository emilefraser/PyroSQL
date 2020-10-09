SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Stats].[Scores](
	[testid] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[studentid] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[score] [tinyint] NOT NULL
) ON [PRIMARY]

GO
