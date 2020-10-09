SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DTA_reports_queryindex](
	[QueryID] [int] NOT NULL,
	[SessionID] [int] NOT NULL,
	[IndexID] [int] NOT NULL,
	[IsRecommendedConfiguration] [bit] NOT NULL
) ON [PRIMARY]

GO
