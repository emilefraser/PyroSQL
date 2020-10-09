SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ASSESS].[AssessmentResponse](
	[AssessmentResponseID] [int] IDENTITY(1,1) NOT NULL,
	[AssessmentResponseDateTime] [datetime2](7) NULL,
	[AssessmentID] [int] NULL,
	[RespondentID] [int] NULL
) ON [PRIMARY]

GO
