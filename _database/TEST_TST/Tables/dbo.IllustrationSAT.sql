SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[IllustrationSAT](
	[IllustrationVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Diagram] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
