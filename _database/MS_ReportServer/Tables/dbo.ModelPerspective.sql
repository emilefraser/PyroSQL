SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ModelPerspective](
	[ID] [uniqueidentifier] NOT NULL,
	[ModelID] [uniqueidentifier] NOT NULL,
	[PerspectiveID] [ntext] COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[PerspectiveName] [ntext] COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PerspectiveDescription] [ntext] COLLATE Latin1_General_100_CI_AS_KS_WS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
