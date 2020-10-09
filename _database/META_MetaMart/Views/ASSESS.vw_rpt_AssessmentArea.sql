SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- ====================================================================
-- Create AssessmentArea View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_rpt_AssessmentArea] AS (
SELECT
[AssessmentAreaID],
[AssessmentArea]
FROM [ASSESS].[AssessmentArea]
)

GO
