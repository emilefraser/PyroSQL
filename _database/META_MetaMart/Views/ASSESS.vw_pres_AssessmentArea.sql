SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- ====================================================================
-- Create AssessmentArea View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_pres_AssessmentArea] AS (
SELECT
[AssessmentAreaID] AS [Assessment Area ID],
[AssessmentArea] AS [Assessment Area Description]
FROM [ASSESS].[vw_rpt_AssessmentArea]
)

GO
