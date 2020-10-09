SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- ====================================================================
-- Create QuestionToAreaMap View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_pres_QuestionToAreaMap] AS (
SELECT
[QuestionToAreaMapID] AS [Question To Area Map ID],
[QuestionID] AS [Question ID],
[AssessmentAreaID] AS [Assessment Area ID]
FROM [ASSESS].[vw_rpt_QuestionToAreaMap]
)

GO
