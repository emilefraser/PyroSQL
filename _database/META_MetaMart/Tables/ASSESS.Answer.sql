SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ASSESS].[Answer](
	[AnswerID] [int] IDENTITY(1,1) NOT NULL,
	[AssessmentResponseID] [int] NULL,
	[AnswerOptionID] [int] NULL,
	[QuestionID] [int] NULL
) ON [PRIMARY]

GO
