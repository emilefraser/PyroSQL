SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ASSESS].[AnswerOptionLevel](
	[AnswerOptionLevelID] [int] IDENTITY(1,1) NOT NULL,
	[AnswerOptionLevel] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Score] [decimal](18, 0) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
