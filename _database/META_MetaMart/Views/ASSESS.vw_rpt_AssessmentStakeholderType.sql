SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- ====================================================================
-- Create AssessmentStakeholderType View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_rpt_AssessmentStakeholderType] AS (
SELECT
[AssessmentStakeholderTypeID],
[AssessmentStakeholderType]
FROM [ASSESS].[AssessmentStakeholderType]
)

GO
