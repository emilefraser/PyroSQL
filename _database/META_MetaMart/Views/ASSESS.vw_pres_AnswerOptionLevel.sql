SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- ====================================================================
-- Create AnswerOptionLevel View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_pres_AnswerOptionLevel] AS (
SELECT
[AnswerOptionLevelID] AS [Answer Option Level ID],
[AnswerOptionLevel] AS [Answer Option Level Description],
[Score] AS [Answer Option Level Score]
FROM [ASSESS].[vw_rpt_AnswerOptionLevel]
)

GO
