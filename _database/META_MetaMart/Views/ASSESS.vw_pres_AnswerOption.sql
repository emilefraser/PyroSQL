SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- ====================================================================
-- Create AnswerOption View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_pres_AnswerOption] AS (
SELECT
[AnswerOptionID] AS [Answer Option ID],
[AnswerOption] AS [Answer Option Description],
[QuestionID] AS [Question ID],
[AnswerOptionLevelID] AS [Answer Option Level ID]
FROM [ASSESS].[vw_rpt_AnswerOption]
)

GO
