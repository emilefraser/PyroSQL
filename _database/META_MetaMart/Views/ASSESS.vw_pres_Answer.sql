SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- ====================================================================
-- Create Answer View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_pres_Answer] AS (
SELECT
[A].[AnswerID] AS [Answer ID],
[A].[AssessmentResponseID] AS [Assessment Response ID],
[A].[QuestionID] AS [Question ID],
[A].[AnswerOptionID] AS [Selected Answer Option ID],
(SELECT [AOL].[Score] FROM [ASSESS].[vw_rpt_AnswerOptionLevel] AS AOL 
LEFT JOIN [ASSESS].[vw_rpt_AnswerOption] AS AO ON AOL.AnswerOptionLevelID = AO.AnswerOptionLevelID
WHERE [AO].[QuestionID] = [A].[QuestionID] AND [AO].[AnswerOptionID] = [A].[AnswerOptionID]) AS [Answer Option Level Score]
FROM [ASSESS].[vw_rpt_Answer] AS [A] 
)

GO
