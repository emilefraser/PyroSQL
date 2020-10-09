SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- ====================================================================
-- Create AssessmentResponse View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_rpt_AssessmentResponse] AS (
SELECT
[AssessmentResponseID],
[AssessmentResponseDateTime],
[RespondentID],
[AssessmentID]
FROM [ASSESS].[AssessmentResponse]
)

GO
