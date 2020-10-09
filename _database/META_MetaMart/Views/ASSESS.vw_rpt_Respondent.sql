SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- ====================================================================
-- Create Respondent View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_rpt_Respondent] AS (
SELECT
[RespondentID],
[RespondentName],
[CustomerID],
[AssessmentStakeholderTypeID]
FROM [ASSESS].[Respondent]
)

GO
