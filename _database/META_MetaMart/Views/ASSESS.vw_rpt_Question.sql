SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- ====================================================================
-- Create Question View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_rpt_Question] AS (
SELECT
[QuestionID],
[Question],
[QuestionNo],
[AssessmentStakeholderTypeID]
FROM [ASSESS].[Question]
)

GO
