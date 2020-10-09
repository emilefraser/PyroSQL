SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [INTEGRATION].[DyanmicADFLoadStructure](
	[Source] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Target] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Cols] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[WaterMarkColumn] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[WaterMarkValue] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Enabled] [bit] NOT NULL,
	[SourceType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TargetType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
