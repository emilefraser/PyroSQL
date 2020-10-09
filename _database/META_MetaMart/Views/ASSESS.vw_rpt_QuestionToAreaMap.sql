SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- ====================================================================
-- Create QuestionToAreaMap View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_rpt_QuestionToAreaMap] AS (
SELECT
[QuestionToAreaMapID],
[QuestionID],
[AssessmentAreaID]
FROM [ASSESS].[QuestionToAreaMap]
)

GO
