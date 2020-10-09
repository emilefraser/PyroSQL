SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- ====================================================================
-- Create AnswerOptionLevel View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_rpt_AnswerOptionLevel] AS (
SELECT
[AnswerOptionLevelID],
[AnswerOptionLevel],
[Score]
FROM [ASSESS].[AnswerOptionLevel]
)

GO
