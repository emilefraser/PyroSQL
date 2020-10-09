SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- ====================================================================
-- Create Question View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_pres_Question] AS (
SELECT
[QuestionID] AS [Question ID],
[Question] AS [Question Description],
[QuestionNo] AS [Question No],
[AssessmentStakeholderTypeID] AS [Assessment Stakeholder Type ID]
FROM [ASSESS].[vw_rpt_Question]
)

GO
