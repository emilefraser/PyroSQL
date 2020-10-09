SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- ====================================================================
-- Create QuestionOption View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_pres_QuestionOption] AS (
SELECT
[QuestionOptionID] AS [Question Option ID],
[QuestionOption] AS [Question Option],
[QuestionID] AS [Question ID],
[QuestionOptionLevelID] AS [Question Option Level ID]
FROM [ASSESS].[vw_rpt_QuestionOption]
)

GO
