SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- ====================================================================
-- Create Respondent View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_pres_Respondent] AS (
SELECT
[RespondentID] AS [Respondent ID],
[RespondentName] AS [Respondent Name],
[CustomerID] AS [Customer ID],
[AssessmentStakeholderTypeID] AS [Assessment Stakeholder Type ID]
FROM [ASSESS].[vw_rpt_Respondent]
)

GO
