SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- ====================================================================
-- Create QuestionOption View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_rpt_QuestionOption] AS (
SELECT
[QuestionOptionID],
[QuestionOption],
[QuestionID],
[QuestionOptionLevelID]
FROM [ASSESS].[QuestionOption]
)

GO
