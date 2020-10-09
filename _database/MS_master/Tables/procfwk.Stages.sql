SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [procfwk].[Stages](
	[StageId] [int] IDENTITY(1,1) NOT NULL,
	[StageName] [varchar](225) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StageDescription] [varchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Enabled] [bit] NOT NULL
) ON [PRIMARY]

GO
