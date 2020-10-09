SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- ====================================================================
-- Create AssessmentStakeholderType View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_pres_AssessmentStakeholderType] AS (
SELECT
[AssessmentStakeholderTypeID] AS [Assessment Stakeholder Type ID],
[AssessmentStakeholderType] AS [Assessment Stakeholder Type Description]
FROM [ASSESS].[vw_rpt_AssessmentStakeholderType]
)

GO
