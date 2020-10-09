SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- ====================================================================
-- Create Answer View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_rpt_Answer] AS (
SELECT
[AnswerID],
[AssessmentResponseID],
[QuestionID],
[AnswerOptionID]
FROM [ASSESS].[Answer]
)

GO
