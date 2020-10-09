SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DTA_reports_query](
	[QueryID] [int] NOT NULL,
	[SessionID] [int] NOT NULL,
	[StatementType] [smallint] NOT NULL,
	[StatementString] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CurrentCost] [float] NOT NULL,
	[RecommendedCost] [float] NOT NULL,
	[Weight] [float] NOT NULL,
	[EventString] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EventWeight] [float] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
