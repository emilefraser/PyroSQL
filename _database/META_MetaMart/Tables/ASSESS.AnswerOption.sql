SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ASSESS].[AnswerOption](
	[AnswerOptionID] [int] IDENTITY(1,1) NOT NULL,
	[AnswerOption] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[QuestionID] [int] NULL,
	[AnswerOptionLevelID] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
