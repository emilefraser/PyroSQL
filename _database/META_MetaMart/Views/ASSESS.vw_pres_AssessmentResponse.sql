SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- ====================================================================
-- Create AssessmentResponse View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_pres_AssessmentResponse] AS (
SELECT
[AssessmentResponseID] AS [Assessment Response ID],
[AssessmentResponseDateTime] AS [Assessment Response DT],
[RespondentID] AS [Respondent ID],
[AssessmentID] AS [Assessment ID]
FROM [ASSESS].[vw_rpt_AssessmentResponse]
)

GO
