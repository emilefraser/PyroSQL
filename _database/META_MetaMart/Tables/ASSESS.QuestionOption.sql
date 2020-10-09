SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ASSESS].[QuestionOption](
	[QuestionOptionID] [int] IDENTITY(1,1) NOT NULL,
	[QuestionOption] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[QuestionOptionLevelID] [int] NULL,
	[QuestionID] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
