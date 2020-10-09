SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ASSESS].[QuestionToAreaMap](
	[QuestionToAreaMapID] [int] IDENTITY(1,1) NOT NULL,
	[AssessmentAreaID] [int] NULL,
	[QuestionID] [int] NULL
) ON [PRIMARY]

GO
