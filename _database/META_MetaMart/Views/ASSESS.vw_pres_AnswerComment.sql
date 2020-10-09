SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- ====================================================================
-- Create AnswerComment View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_pres_AnswerComment] AS (
SELECT
[AnswerCommentID] AS [Answer Comment ID],
[Comment] AS [Comment],
[AnswerID] AS [Answer ID]
FROM [ASSESS].[vw_rpt_AnswerComment]
)

GO
