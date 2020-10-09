SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ASSESS].[Question](
	[QuestionID] [int] IDENTITY(1,1) NOT NULL,
	[Question] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[QuestionNo] [int] NULL,
	[AssessmentStakeholderTypeID] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
