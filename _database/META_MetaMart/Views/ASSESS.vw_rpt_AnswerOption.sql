SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- ====================================================================
-- Create AnswerOption View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_rpt_AnswerOption] AS (
SELECT
[AnswerOptionID],
[AnswerOption],
[QuestionID],
[AnswerOptionLevelID]
FROM [ASSESS].[AnswerOption]
)

GO
